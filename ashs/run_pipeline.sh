#!/bin/bash -x

cmd=$(basename "$0")
DayInSeconds=$(echo $((24 * 60 * 60)))

syntax="$cmd [-d outputdir] {-s ASHS-HarP|ASHS-Magdeburg|ASHS-PMC-T1|ASHS-PMC-T2|ASHS-Princeton|ASHS-Utrecht} {-T {T1-InputFile.{dicom.zip|.nii.gz}} {-t {T2-InputFile.{dicom.zip|.nii.gz}}"

# AshsHarp - T1
# Ashs-Magdeburg - T2 (7T)
# Ashs-PMC-T1 (3T)
# Ashs-PMC-T2 (3T)
# Ashs-Princeton - T2 (7T)
# Ashs-Utrecht - T1 (3T)

function niftiIfNeeded {
    local InputFile="$1"
    local NiftiFile
    
    # Convert to nifi if needed
    if echo "$InputFile" | grep -q ".nii.gz$"
    then
	NiftiFile="$InputFile"
    elif echo "$InputFile" | grep -q ".dicom.zip$"
    then
	DicomDir="${TmpDir}/DicomDir"
	mkdir -p "$DicomDir"

	NiftiFile="${TmpDir}/$(basename "$InputFile" | sed 's/.dicom.zip$/.nii.gz/')"
	unzip -qq -j -d "$DicomDir" "$InputFile" 
	SeriesID="$(c3d -dicom-series-list "$DicomDir" | tail -n 1 | awk '{print $NF}')"

	# -dicom takes two arguments so  -o follows 
	c3d -dicom-series-read "$DicomDir" "$SeriesID" -o "$NiftiFile" 
	rm -rf "$DicomDir"
    else
	echo "$cmd : Unrecognized input type '$InputFile'" 1>&2
	exit 1
    fi

    echo "$NiftiFile"
}

#
# User input is used to select which valid input to return.
# Do not return user input under any circumstances
#
function checkDSSService {
    local Service="$1"
    
    if echo -q "$Service" | grep -q ASHS-PMC-T2
    then
	Service=ASHS-PMC
    fi

    ValidServices=(ASHS-HarP ASHS-Magdeburg ASHS-PMC-T1 ASHS-PMC ASHS-Princeton ASHS-Utrecht)
    for i in "${ValidServices[@]}"
    do
	if echo "$Service" | grep -i -q "^$i$"
	then
	    echo "$i"
	    return 0
	fi
    done

    if echo "$Service" | grep -q '^[0-9][0-9]*$' &&  [ -n "${ValidServices[$Service]}" ]
    then
	echo "${ValidServices[$Service]}"
	return 0
    fi

    return 1
}

while getopts "d:s:T:t:" arg
do
	case "$arg" in
        	d|s|T|t)
		    eval "opt_${arg}='${OPTARG:=1}'"
		    ;;
	esac
done

shift $(($OPTIND - 1))

if [ -z "$opt_s" ]
then
    echo "$cmd : Missing service" 1>&2
    echo "$syntax" 1>&2
    exit 1
fi

Service=$(checkDSSService "$opt_s")
if [ -z "$Service" ]
then
    echo "$cmd : bad service '$opt_s'" 1>&2
    echo "$syntax" 1>&2
    exit 1
fi

if [ -z "$opt_T" ]
then
    echo "$cmd : Missing T1 File" 1>&2
    echo "$syntax" 1>&2
    exit 1
fi

if [ -z "$opt_t" ]
then
    echo "$cmd : Missing T2 File" 1>&2
    echo "$syntax" 1>&2
    exit 1
fi

if [ -n "$opt_d" ]
then
	OutputDir="$opt_d"
else
	OutputDir="."
fi

TmpDir=$(mktemp -d "/tmp/${cmd}-XXXXX")
WorkspaceFile="${TmpDir}/WorkspaceFile"
TicketFile="$TmpDir/TicketFile"    

T1NiftiFile=$(niftiIfNeeded "$opt_T")
 
# Authorization token is in ~/.alfabis/cookie*.jar
# -o is a file
# -i looks like it needs to be .nii.gz
if [ "$Service" == "ASHS-HarP" ]
then
    T1Tag=T1
else
    T1Tag=T1-MRI
fi

ITKSnapCmd=( itksnap-wt -layers-add-anat "$T1NiftiFile" -tags-add "$T1Tag" -layers-list -o "$WorkspaceFile" )

if [ -n "$opt_t" -a "$opt_t" != 1 ]
then
    T2NiftiFile=$(niftiIfNeeded "$opt_t")
    ITKSnapCmd+=(-layers-add-anat "$T2NiftiFile" -tags-add "T2-MRI")
fi

"${ITKSnapCmd[@]}"

for i in $(itksnap-wt -dss-tickets-list | grep -P 'success|failed' | awk '{print $2}')
do
	itksnap-wt -dss-tickets-delete $i
done

itksnap-wt -i "$WorkspaceFile" -dss-tickets-create "$Service" > "$TicketFile"

TicketNumber=$(awk '/2>/ {printf "%08d\n", $2}' "$TicketFile")
if [ -z "$TicketNumber" ]
then
    echo "$cmd : Could not find ticket number in '$TicketFile'" 1>&2
    exit 2
fi

itksnap-wt -dss-tickets-wait "$TicketNumber" "$DayInSeconds"
# Creates layer_00{0,1,2}_*.nii.gz ticket_%08d_results.itksnap

ITKSnapOutputDir="$TmpDir/ITKSnapOutputDir"
mkdir "$ITKSnapOutputDir"

itksnap-wt -dss-tickets-download "$TicketNumber" "$ITKSnapOutputDir"

ITKSnapFile="${ITKSnapOutputDir}/ticket_${TicketNumber}_results.itksnap"
#
# Layer 000 goes to index 0, layer 001, goes to index 1 etc.
#
Layers=($(itksnap-wt -i "$ITKSnapFile" -layers-list | sort -n  | awk '/2> [0-9]+/ {print $5}'))

#
# *** Probably want to rename each layer to something sensible.
#
for Layer in "${Layers[@]}"
do
    cp "$Layer" "$OutputDir"
done
cp "$ITKSnapFile" $OutputDir

itksnap-wt -dss-tickets-delete "$TicketNumber"

# rm -rf "$Tmpdir"
