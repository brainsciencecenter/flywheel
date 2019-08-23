#!/bin/bash -x

set -x 

export PATH=$FLYWHEEL:$PATH

# ------------------------------------
# Generate a clinical report
# ------------------------------------

# Print usage by default
if [[ $# -lt 1 || $1 == "h" || $1 == "-help" || $1 == "--help" ]] ; then
  cat << USAGETEXT
    generate_pdf_report.sh: Script to create a pdf clinical report
    usage: 
      generate_pdf_report.sh [options]
    options:
      -s  <str>         : Session ID number
      -n  <str>         : Scan number
      -t  <str>         : Ticket number
      -a  <years>       : Patient's age
      -w  <dir>         : Location of the work directory where the output should be generated
USAGETEXT
  exit 0
fi 

# Read the options
while getopts "i:s:n:t:a:c:h:w:" opt; do
    #echo "getopts found option $opt"
    case $opt in

	s) 
	    session_id=$OPTARG
	    #echo "$OPTARG"
	    ;;
	n)
            scan_id=$OPTARG
            #echo "$OPTARG"
            ;;
	t) 
	    ticket=$OPTARG
	    #echo "$OPTARG"
	    ;;	
	a) 
	    age=$OPTARG
	    #echo "$OPTARG"
	    ;;
	w)
            OUTPUTDIR=$OPTARG
            echo "$OPTARG"
            ;;
	
	i)
            INPUTDIR=$OPTARG
            echo "$OPTARG"
            ;;
	
	\?) echo "Unknown option $OPTARG"; exit 2;;

	:) echo "Option $OPTARG requires an argument"; exit 2;;

    esac
done

# Locate the input files and set the output path 
rmdf=$INPUTDIR/clinical_report.Rmd
ndf=$INPUTDIR/ADNI_metadata_for_R.csv

full_id=${session_id}_${scan_id}
report=${full_id}_report.pdf
tex=${full_id}_report.tex

# Get the HARP and ICV segmentation files from the workdirectory
icv_layer=$INPUTDIR/${full_id}_icv.nii.gz
harp_layer=$INPUTDIR/${full_id}_harp.nii.gz

# Generate the ICV volumes out of the segmentation file
extent=$(c3d $icv_layer -dup -lstat | awk -v id=101 '$1 == id {print $10}')
if [[ $extent ]] ; then
        icv=$(c3d $icv_layer -dup -lstat | awk -v id=101 '$1 == id {print $7}')
	echo "$session_id ICV $extent $icv" > $INPUTDIR/${full_id}_icv_volumes.txt
fi 

# Generate the HARP Left volumes out of the segmentation file
extent=$(c3d $harp_layer -dup -lstat | awk -v id=102 '$1 == id {print $10}')
if [[ $extent ]] ; then
	hvl=$(c3d $harp_layer -dup -lstat | awk -v id=102 '$1 == id {print $7}')
        echo "$session_id HVL $extent $hvl" > $INPUTDIR/${full_id}_harp_left_volumes.txt
fi

# Generate the HARP Right volumes out of the segmentation file
extent=$(c3d $harp_layer -dup -lstat | awk -v id=103 '$1 == id {print $10}')
if [[ $extent ]] ; then
	hvr=$(c3d $harp_layer -dup -lstat | awk -v id=103 '$1 == id {print $7}')
        echo "$session_id HVR $extent $hvr" > $INPUTDIR/${full_id}_harp_right_volumes.txt
fi

# Get the HARP and ICV segmentation files from source directories
#icv=$(cat $ICVDIR/final/${ticket}_left_corr_usegray_volumes.txt| awk -F' ' '{ print $5 }')
#hvl=$(cat $HARPDIR/final/${ticket}_left_corr_usegray_volumes.txt| awk -F' ' '{ print $5 }')
#hvr=$(cat $HARPDIR/final/${ticket}_right_corr_usegray_volumes.txt| awk -F' ' '{ print $5 }')

# Get the QA files from source directories
qaicv=$INPUTDIR/multiatlas_corr_nogray_icv_qa.png
qahvl=$INPUTDIR/bootstrap_corr_nogray_harp_left_qa.png
qahvr=$INPUTDIR/bootstrap_corr_nogray_harp_right_qa.png

wget $(echo "$(itksnap-wt -dss-tickets-log $ticket | grep ICV | grep multiatlas | grep nogray | grep left | awk '{print $2}')") -O $qaicv
wget $(echo "$(itksnap-wt -dss-tickets-log $ticket | grep HARP | grep bootstrap | grep nogray | grep left | awk '{print $2}')") -O $qahvl
wget $(echo "$(itksnap-wt -dss-tickets-log $ticket | grep HARP | grep bootstrap | grep nogray | grep right | awk '{print $2}')") -O $qahvr

echo "$OUTPUTDIR"

# Cut the QA images to extract only interesting part
qaicv_croped=$INPUTDIR/${full_id}_qa_icv.png
qahvl_croped=$INPUTDIR/${full_id}_qa_harp_left.png
qahvr_croped=$INPUTDIR/${full_id}_qa_harp_right.png

w=$(c3d $qaicv -info-full | grep "Image Dimensions" | awk '{print $4}' | sed 's/[[,]//g')
h=$(c3d $qaicv -info-full | grep "Image Dimensions" | awk '{print $5}' | sed 's/[[,]//g')
s=$(python -c "print( ${h}/3 - ${h}*1/100 )")
echo "$w $h $s"
convert $qaicv -crop ${w}x${h}+0+$s $qaicv_croped

w=$(c3d $qahvl -info-full | grep "Image Dimensions" | awk '{print $4}' | sed 's/[[,]//g')
h=$(c3d $qahvl -info-full | grep "Image Dimensions" | awk '{print $5}' | sed 's/[[,]//g')
s=$(python -c "print( ${h}/3 - ${h}*3/100 )")
echo "$w $h $s"
convert $qahvl -crop ${w}x${h}+0+$s $qahvl_croped

w=$(c3d $qahvr -info-full | grep "Image Dimensions" | awk '{print $4}' | sed 's/[[,]//g')
h=$(c3d $qahvr -info-full | grep "Image Dimensions" | awk '{print $5}' | sed 's/[[,]//g')
s=$(python -c "print( ${h}/3 - ${h}*3/100 )")
echo "$w $h $s"
convert $qahvr -crop ${w}x${h}+0+$s $qahvr_croped

#convert $qahvl -crop 344x92+0+46 $qahvl_croped
#convert $qahvr -crop 344x92+0+46 $qahvr_croped

echo -e "RMarkdown file:\n$rmdf\n"
echo -e "Patient:\n$id - $age\n"
echo -e "Volumes:\n$icv - $hvl - $hvr \n" 
echo -e "Normative Data:\n$ndf \n"
echo -e "QA:\n $(basename $qaicv) \n $(basename $qahvl) \n $(basename $qahvr) \n"
echo -e "QA:\n $(basename $qaicv_croped) \n $(basename $qahvl_croped) \n $(basename $qahvr_croped) \n"

# Call R to create the report with correct parameters
R -e "rmarkdown::render('$rmdf',output_file = '$report', params = list( PID = '$session_id', PAGE = $age, PICV = as.double($icv), PHVL = as.double($hvl), PHVR = as.double($hvr), NDF = '$ndf', QAICV = '$qaicv_croped', QAHVL = '$qahvl_croped', QAHVR = '$qahvr_croped'))"

cp "$INPUTDIR"/"$report" "$OUTPUTDIR"

ls -l $INPUTDIR

