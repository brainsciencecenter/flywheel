# 

import "Id2Labels" as $Id2Labels;

#import "Id2ProjectLabels" as $ProjectId2Labels;
#import "Id2SubjectLabels" as $SubjectId2Labels;
#import "Id2SessionLabels" as $SessionId2Labels;
import "Id2Labels" as $Id2Labels;
import "SessionId2Notes" as $SessionId2Notes;
import "SessionId2TimestampsActive" as $SessionId2TimestampsActive;
import "SessionId2Tags" as $SessionId2Tags;

      .parents.group as $GroupLabel 
    | .parents.project as $ProjectId
    | .parents.subject as $SubjectId
    | .parents.session as $SessionId

    | $Id2Labels::Id2Labels[][.parents.project] as $ProjectLabel 
    | $Id2Labels::Id2Labels[][.parents.subject] as $SubjectLabel 
    | $Id2Labels::Id2Labels[][.parents.session] as $SessionLabel 
    | $SessionId2Notes::SessionId2Notes[][.parents.session] as $SessionNotes
    | $SessionId2TimestampsActive::SessionId2TimestampsActive[][.parents.session] as $SessionTimestamp
    | $SessionId2Tags::SessionId2Tags[][$SessionId] as $SessionTags

    | ._id as $AcquisitionId
    | .label as $AcquisitionLabel

    | (if .info.PICSL_sMRI_biomarkers.ICV then .info.PICSL_sMRI_biomarkers.ICV else "None" end) as $Icv
    | (if .info.PICSL_sMRI_biomarkers.LeftHippocampusVolume then .info.PICSL_sMRI_biomarkers.LeftHippocampusVolume else "None" end) as $LeftHippocampusVolume
    | (if .info.PICSL_sMRI_biomarkers.RightHippocampusVolume then .info.PICSL_sMRI_biomarkers.RightHippocampusVolume else "None" end) as $RightHippocampusVolume
    | (if .info.PICSL_sMRI_biomarkers.JobId then .info.PICSL_sMRI_biomarkers.JobId else "None" end) as $AshsJobId
    | (if .info.PICSL_sMRI_biomarkers.JobUrl then .info.PICSL_sMRI_biomarkers.JobUrl else "None" end) as $AshsJobUrl
    | (if .info.PICSL_sMRI_biomarkers.DateTime then .info.PICSL_sMRI_biomarkers.DateTime else "None" end) as $AshsJobDateTime


    | (if (.timestamp) then .timestamp else .created end) as $Timestamp

    # Only select the first .dicom.zip
    | .files
#    | [([.[] | select(.name|match("."+$DicomExt+"$"))]|first) , ([.[] | select(.name|match("."+$NiftiExt+"$"))]|first)]|map(select(.))
    | [.[] | if $Bids then select(.info.BIDS) else select((.name | match("(("+$DicomExt+")|("+$NiftiExt+"))$"))) end] | first



      | .name as $AcquisitionFileName
      | .type as $AcquisitionType
      | .size as $AcquisitionSize
      | (if .classification.Intent then .classification.Intent|join(";") else "None" end) as $Intent
      | (if .classification.Measurement then .classification.Measurement|join(";") else "None" end) as $Measurement
      | (if .classification.Features then .classification.Features|join(";") else "" end) as $Features
      | .info

	# Need to check file names for ^IND{1,2}_.*$, ^\d{6}$, ^\d{6}[._\-x]\d{2}$

	| [ 
	    $SubjectLabel,
	    $ProjectLabel,
	    $SubjectLabel,
	    (if $SessionTimestamp then $SessionTimestamp else "1900-01-01T00:00:00+00:00" end),
	    "https://upenn.flywheel.io/#/projects/\($ProjectId)/sessions/\($SessionId)?tab=data",
	    $SessionId,
	    $SessionLabel,
	    $SessionTags,
	    (if $SessionNotes then ($SessionNotes | sub("\\n"; " "; "gm")) else "" end),
	    $ProjectId,
	    $AcquisitionLabel,
	    $AcquisitionType,
	    $AcquisitionSize,
	    $Intent,
	    $Measurement,
	    $Features,
	    $AcquisitionId,
	    ( if $Timestamp then $Timestamp else "1900-01-01T00:00:00+0000" end),
	    .Modality,
	    .InstitutionName,
	    .StationName,
	    (if .BodyPartExamined then .BodyPartExamined else "None" end),
	    .StudyInstanceUID,
	    .SeriesInstanceUID,
	    .SliceThickness,
	    .PixelSpacing[0],
	    .PixelSpacing[1],

	    $Icv,
	    $LeftHippocampusVolume,
	    $RightHippocampusVolume,
#	    $AshsJobId,
#	    $AshsJobUrl,
#	    $AshsJobDateTime,

	    $AcquisitionFileName,

	    # BIDS
	    (
	      if ( .BIDS and ((.BIDS|type) == "object") ) then 
	        "Bids",
		.BIDS.Acq,
		.BIDS.Ce,
		.BIDS.Dir,
		.BIDS.Trc,
		.BIDS.Echo,
		.BIDS.Filename,
		.BIDS.Folder,
		if ((.BIDS.IntendedFor|type) == "array" ) then
		   [(.BIDS.IntendedFor[][]|values)]|join(":")
		else
		  .BIDS.IntendedFor
		end,
		.BIDS.Mod,
		.BIDS.Modality,
		.BIDS.Path,
		.BIDS.Rec,
		.BIDS.Run,
		.BIDS.Task,
		.BIDS.error_message,
		.BIDS.Ignore,
		.BIDS.template,
		.BIDS.valid
	      else
	        "NoBid",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                ""
              end
            ),

	    # MRI
	    .MagneticFieldStrength,
	    .SequenceName,
	    .RepetitionTime,
	    .EchoTime,
	    .EchoNumbers,
	    .FlipAngle,
	    .NumberOfAverages,
	    .AcquisitionNumber,
	    .SpacingBetweenSlices,

	    # PET
	    .ReconstructionMethod,
	    .ScatterCorrectionMethod,
	    .AttenuationCorrectionMethod,
	    (if .RadiopharmaceuticalInformationSequence and .RadiopharmaceuticalInformationSequence.Radiopharmaceutical then .RadiopharmaceuticalInformationSequence.Radiopharmaceutical else "NONE" end),
	    (if     .RadiopharmaceuticalInformationSequence 
	    	and .RadiopharmaceuticalInformationSequence.RadionuclideCodeSequence 
		and .RadiopharmaceuticalInformationSequence.RadionuclideCodeSequence.CodeMeaning
	      then
		    .RadiopharmaceuticalInformationSequence.RadionuclideCodeSequence.CodeMeaning
              else
		    "None"
	      end)

	  ] | @csv
