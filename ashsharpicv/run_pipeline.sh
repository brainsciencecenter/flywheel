#!/bin/bash -x
set -x -e

# Print usage by default
if [[ $# -lt 1 || $1 == "h" || $1 == "-help" || $1 == "--help" ]] ; then
  cat << USAGETEXT

	run_pipeline.sh: Script to run the whole pipeline. It sends a ticket for the
                         HARP-ICV segmentation service and generates a pdf report 
    	                 out of the results.
    	usage: 
      		run_pipeline.sh [options] [DICOMDIR|nifti-file.gz]
   	options:
		-p  <str>         : Project's name
		-s  <str>         : MR session ID number
      		-n  <str>         : Scan ID number
		-a  <years>       : Patient's age

USAGETEXT
  exit 0
fi 

# Read the options
while getopts "p:s:n:a:" opt; do
    #echo "getopts found option $opt"
	case $opt in
	
        	p)
			project=$OPTARG
			echo "$project"
			;;
		s)
			session_id=$OPTARG
			echo "$session_id"
        		;;
		n)
			scan_id=$OPTARG
			echo "$scan_id"
			;;
		a)
			age=$OPTARG
			echo "$age"
			;;

		\?) echo "Unknown option $OPTARG"; exit 2;;

		:) echo "Option $OPTARG requires an argument"; exit 2;;
	esac
done

shift $(($OPTIND - 1))

INPUTDIR="$1"
OUTPUTDIR="$2"
TMPDIR=$(mktemp -d /tmp/pipeline-XXXXX)

full_id=${session_id}_${scan_id}

native_image=${full_id}_native_mri.nii.gz
input_image=${full_id}_mri.nii.gz

if [ ! -d $TMPDIR ] ; then mkdir -p $TMPDIR ; fi

if [ -f "$INPUTDIR" ]
then
	cp "$INPUTDIR" "$TMPDIR/$native_image"
elif [ -d "$INPUTDIR" ] ; then 
	c3d -dicom-series-list $INPUTDIR 
	series_id=$(c3d -dicom-series-list $INPUTDIR | grep 2 | awk '{ print $NF }')
	c3d -dicom-series-read $INPUTDIR $series_id -o $TMPDIR/$native_image
else
	echo "The folder $INPUTDIR doesn't exist."
	exit 1
fi

# Check the image
width=$(c3d $TMPDIR/$native_image -info-full | grep "Image Dimensions" | awk '{print $4}' | sed 's/[[,]//g')
height=$(c3d $TMPDIR/$native_image -info-full | grep "Image Dimensions" | awk '{print $5}' | sed 's/[[,]//g')
sx=$(c3d $TMPDIR/$native_image -info-full | grep "Voxel Spacing" | awk '{print $4}' | sed 's/[][,]//g')
sy=$(c3d $TMPDIR/$native_image -info-full | grep "Voxel Spacing" | awk '{print $5}' | sed 's/[][,]//g')
sz=$(c3d $TMPDIR/$native_image -info-full | grep "Voxel Spacing" | awk '{print $6}' | sed 's/[][,]//g')
smax=$(python -c "print(max([$sx,$sy,$sz]))")
smin=$(python -c "print(min([$sx,$sy,$sz]))")
aspect_ratio_min=$(python -c "print( float($smin)/float($smax))")
aspect_ratio_max=$(python -c "print( float($smax)/float($smin))")

if (( $width > 40 )) && (( $height > 40 )) ; then 
	if [[ $(echo "$aspect_ratio_max < 3" | bc) == 1 ]] && [[ $(echo "$aspect_ratio_min > 0.33" | bc) == 1 ]] ; then	
		trim_script=./trim_neck.sh
		MASKDIR=$TMPDIR/mask
		INTERDIR=$TMPDIR/inter
		if [ ! -d $MASKDIR ] ; then mkdir -p $MASKDIR ; fi  
		if [ ! -d $INTERDIR ] ; then mkdir -p $INTERDIR ; fi
		$trim_script -m $MASKDIR -w $INTERDIR $TMPDIR/$native_image $TMPDIR/$input_image
	else 
		echo "Wrong scan input: the aspect ratio of the image is < 0.33 or > 3."
		exit 1
	fi
else
	echo "Wrong scan input: the width or/and the height of image is inferior to 40."
        exit 1	 
fi 

# Create input workspace
input_workspace=${full_id}_input.itksnap
itksnap-wt -laa $TMPDIR/$input_image -ta T1 -psn "MRI" -ll -o $TMPDIR/$input_workspace


for i in $(itksnap-wt -dss-tickets-list | grep -P 'success|failed' /tmp/cookies | awk '{print $2}')
do
        itksnap-wt -dss-tickets-delete $i
done

# Create ticket with the HARP-ICV service number
service=ASHS-HarP
ticket_create_out=$TMPDIR/${full_id}_ticket_info.txt

if [ -f $ticket_create_out ] ; then rm $ticket_create_out ; fi
touch $ticket_create_out
chmod 755 $ticket_create_out

itksnap-wt -i $TMPDIR/$input_workspace -dss-tickets-create $service > $ticket_create_out
ticket_number=$(cat $ticket_create_out | grep "^2> " | awk '{print $2}')
ticket_code=$(printf %08d $ticket_number)

# Check the processing of the ticket
sleep 30s
itksnap-wt -dss-tickets-wait $ticket_number 86400
sleep 30s

# Rename result files
itksnap-wt -dss-tickets-download $ticket_number $TMPDIR 
ticket_workspace=$TMPDIR/ticket_${ticket_code}_results.itksnap
xnat_workspace=$TMPDIR/${full_id}_results.itksnap

mri_layer=$(itksnap-wt -i $ticket_workspace -ll | grep MRI | awk '{print $2}')
icv_layer=$(itksnap-wt -i $ticket_workspace -ll | grep ICV | awk '{print $2}')
harp_layer=$(itksnap-wt -i $ticket_workspace -ll | grep HARP | awk '{print $2}')

itksnap-wt -i $ticket_workspace \
	        -layers-pick $mri_layer -props-rename-file $TMPDIR/${full_id}_mri.nii.gz \
                -layers-pick $icv_layer -props-rename-file $TMPDIR/${full_id}_icv.nii.gz \
	        -layers-pick $harp_layer -props-rename-file $TMPDIR/${full_id}_harp.nii.gz \
		-o $xnat_workspace

cp "$ticket_workspace" "${TMPDIR}/${full_id}"_{mri,icv,harp}.nii.gz "$OUTPUTDIR"
cp clinical_report.Rmd ADNI_metadata_for_R.csv "$TMPDIR"

make_report.sh -s $session_id \
			  -n $scan_id \
			  -a $age \
			  -t $ticket_code \
			  -i "$TMPDIR" \
			  -w "$OUTPUTDIR"

itksnap-wt -dss-tickets-delete "$ticket_number"
