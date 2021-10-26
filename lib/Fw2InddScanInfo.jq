# INDDID,FlywheelSubjectID,FlywheelSessionTimestampUTC,FlywheelSessionURL,FlywheelSessionInternalID,FlywheelProjectInternalID,FlywheelAcquisitionLabel,FlywheelAcquisitionIntent,FlywheelAcquisitionMeasurement,FlywheelAcquisitionFeatures,FlywheelAcquisitionInternalID,AcquisitionTimestampUTC,DicomModality,DicomInstitutionName,DicomStationName,DicomBodyPartExamined,DicomStudyInstanceUID,DicomSeriesInstanceUID,DicomSliceThickness,DicomPixelSpacingX,DicomPixelSpacingY,BidsNoBids,BidsAcq,BidsCe,BidsDir,BidsTrc,BidsEcho,BidsFilename,BidsFolder,BidsIntendedFor,BidsMod,BidsModality,BidsPath,BidsRec,BidsRun,BidsTask,BidsError_message,BidsIgnore,BidsTemplate,BidsValid,DicomMagneticFieldStrength,DicomSequenceName,DicomRepetitionTime,DicomEchoTime,DicomEchoNumbers,DicomFlipAngle,DicomNumberOfAverages,DicomAcquisitionNumber,DicomSpacingBetweenSlices,DicomReconstructionMethod,DicomScatterCorrectionMethod,DicomAttenuationCorrectionMethod,DicomRadiopharmaceutical,DicomRadionuclide

# 18: BidsNoBids,BidsAcq,BidsCe,BidsDir,BidsTrc,BidsEcho,BidsFilename,BidsFolder,BidsIntendedFor,BidsMod,BidsModality,BidsPath,BidsRec,BidsRun,BidsTask,BidsError_message,BidsIgnore,BidsTemplate,BidsValid,

import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;
import "Id2SessionTimeStamps" as $SessionId2Timestamps;

      .parents.group as $GroupLabel 
    | .parents.project as $ProjectId
    | .parents.subject as $SubjectId
    | .parents.session as $SessionId

    | $ProjectId2Labels::ProjectId2Labels[][.parents.project] as $ProjectLabel 
    | $SubjectId2Labels::SubjectId2Labels[][.parents.subject] as $SubjectLabel 
    | $SessionId2Labels::SessionId2Labels[][.parents.session] as $SessionLabel 
    | $SessionId2Timestamps::SessionId2Timestamps[][.parents.session] as $SessionTimeStamp

    | ._id as $AcquisitionId
    | .label as $AcquisitionLabel 
    | (if (.timestamp) then .timestamp else .created end) as $TimeStamp

    # Only select the first .dicom.zip
    | .files[]
    | select(.name | match("(.dicom.zip)|(.nii.gz)$"))

      | .name as $AcquisitionFileName
      | (if .classification.Intent then .classification.Intent|join(";") else "None" end) as $Intent
      | (if .classification.Measurement then .classification.Measurement|join(";") else "None" end) as $Measurement
      | (if .classification.Features then .classification.Features|join(";") else "" end) as $Features
      | .info

	# Need to check file names for ^IND{1,2}_.*$, ^\d{6}$, ^\d{6}[._\-x]\d{2}$

	| [ 
	    $SubjectLabel,
	    $SubjectLabel,
	    (if $SessionTimeStamp then $SessionTimeStamp else "1900-01-01T00:00:00+00:00" end),
	    "https://upenn.flywheel.io/#/projects/\($ProjectId)/sessions/\($SessionId)?tab=data",
	    $SessionId,
	    $ProjectId,
	    $AcquisitionLabel,
	    $Intent,
	    $Measurement,
	    $Features,
	    $AcquisitionId,
	    ( if $TimeStamp then $TimeStamp else "1900-01-01T00:00:00+0000" end),
	    .Modality,
	    .InstitutionName,
	    .StationName,
	    (if .BodyPartExamined then .BodyPartExamined else "None" end),
	    .StudyInstanceUID,
	    .SeriesInstanceUID,
	    .SliceThickness,
	    .PixelSpacing[0],
	    .PixelSpacing[1],

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
