# 
# include seems to have to come before import
#

include "FwLib";

import "Id2Labels" as $Id2Labels;

import "SessionId2Timestamps" as $SessionId2Timestamps;
import "SessionId2Notes" as $SessionId2Notes;
import "SessionId2Tags" as $SessionId2Tags;

      .parents.group as $GroupLabel 
    | .parents.project as $ProjectId
    | .parents.subject as $SubjectId
    | .parents.session as $SessionId

    | $Id2Labels::Id2Labels[][.parents.project] as $ProjectLabel 
    | $Id2Labels::Id2Labels[][.parents.subject] as $SubjectLabel 
    | $Id2Labels::Id2Labels[][.parents.session] as $SessionLabel 
    | $SessionId2Timestamps::SessionId2Timestamps[][.parents.session] as $SessionTimestamps
    | $SessionId2Notes::SessionId2Notes[][.parents.session] as $SessionNotes
    | $SessionId2Tags::SessionId2Tags[][$SessionId] as $SessionTags

    | ._id as $AcquisitionId
    | .label as $AcquisitionLabel

    | pmbmIcv(.info.PICSL_sMRI_biomarkers) as $Icv
    | pmbmLeftHippocampusVolume(.info.PICSL_sMRI_biomarkers) as $LeftHippocampusVolume
    | pmbmRightHippocampusVolume(.info.PICSL_sMRI_biomarkers) as $RightHippocampusVolume
    | pmbmJobId(.info.PICSL_sMRI_biomarkers) as $AshsJobId
    | pmbmJobDateTime(.info.PICSL_sMRI_biomarkers) as $AshsJobDateTime

    | jobId2JobUrl($AshsJobId) as $AshsJobUrl
    | container2Timestamps(.) as $AcquisitionTimestamps

    | .files
      # Want Bids files and the first NoBids of type Dicom or Nifti
    | [
           # Select the Bids *files*
	   [ .[] | select( ((.info.BIDS | type) == "object") ) ] | first
      ] +
      [
	 [ .[] | select( ((.info.BIDS | type) == "null") and  ((.type == "dicom") or (.type == "nifti")) ) ] | first
      ] | .[]
#    | [ .[] | if $Bids then select(.info.BIDS) else select((.name | test($FileExt))) end] | first
      | .name as $AcquisitionFileName
      | .file_id as $AcquisitionFileId
      | .type as $AcquisitionType
      | .size as $AcquisitionSize
      | (if .classification.Intent then .classification.Intent|join(";") else "None" end) as $Intent
      | (if .classification.Measurement then .classification.Measurement|join(";") else "None" end) as $Measurement
      | (if .classification.Features then .classification.Features|join(";") else "" end) as $Features
      | .info
	        | (if ((.BIDS | type) == "object") then "Bids" else "NoBids" end) as $BidsNoBids
		| (if ((.BIDS | type) == "object") then .BIDS.Acq else "" end) as $BidsAcq
		| (if ((.BIDS | type) == "object") then .BIDS.Ce else "" end) as $BidsCe
		| (if ((.BIDS | type) == "object") then .BIDS.Dir else "" end) as $BidsDir
		| (if ((.BIDS | type) == "object") then .BIDS.Trc else "" end) as $BidsTrc
		| (if ((.BIDS | type) == "object") then .BIDS.Echo else "" end) as $BidsEcho
		| (if ((.BIDS | type) == "object") then .BIDS.Filename else "" end) as $BidsFilename
		| (if ((.BIDS | type) == "object") then .BIDS.Folder else "" end) as $BidsFolder
		| (if ((.BIDS | type) == "object") then (if ((.BIDS.IntendedFor|type) == "array" ) then
				        [(.BIDS.IntendedFor[][]|values)]|join(":")
				    else
					.BIDS.IntendedFor
				    end) else "" end) as $BidsIntendedFor
		| (if ((.BIDS | type) == "object") then .BIDS.Mod else "" end) as $BidsMod
		| (if ((.BIDS | type) == "object") then .BIDS.Modality else "" end) as $BidsModality
		| (if ((.BIDS | type) == "object") then .BIDS.Path else "" end) as $BidsPath
		| (if ((.BIDS | type) == "object") then .BIDS.Rec else "" end) as $BidsRec
		| (if ((.BIDS | type) == "object") then .BIDS.Run else "" end) as $BidsRun
		| (if ((.BIDS | type) == "object") then .BIDS.Task else "" end) as $BidsTask
		| (if ((.BIDS | type) == "object") then .BIDS.error_message else "" end) as $BidsErrorMessage
		| (if ((.BIDS | type) == "object") then .BIDS.Ignore else "" end) as $BidsIgnore
		| (if ((.BIDS | type) == "object") then .BIDS.template else "" end) as $BidsTemplate
		| (if ((.BIDS | type) == "object") then .BIDS.valid else "" end) as $BidsValid

                | (if ( .RadiopharmaceuticalInformationSequence )
                   then
                        .RadiopharmaceuticalInformationSequence | toObject
                      | .Radiopharmaceutical
                   else
                        "None"
                   end) as $DicomRadiopharmaceutical

                | ( if (.RadiopharmaceuticalInformationSequence) then
                        .RadiopharmaceuticalInformationSequence | toObject
                      | .RadionuclideCodeSequence | toObject
                      | .CodeMeaning
                    else
                         "None"
                    end) as $DicomRadionuclide

	# Need to check file names for ^IND{1,2}_.*$, ^\d{6}$, ^\d{6}[._\-x]\d{2}$

	| { 
	      "INDDID": $SubjectLabel
	    , "FlywheelProjectLabel": $ProjectLabel
	    , "FlywheelSubjectLabel": $SubjectLabel
	    , "FlywheelSessionCreatedUTC": (if $SessionTimestamps then $SessionTimestamps.created else "1900-01-01T00:00:00+00:00" end)
	    , "FlywheelSessionModifiedUTC": (if $SessionTimestamps then $SessionTimestamps.modified else "1900-01-01T00:00:00+00:00" end)
	    , "FlywheelSessionTimestampUTC": (if $SessionTimestamps then $SessionTimestamps.timestamp else "1900-01-01T00:00:00+00:00" end)
	    , "FlywheelSessionURL": "https://upenn.flywheel.io/#/projects/\($ProjectId)/sessions/\($SessionId)?tab=data"
	    , "FlywheelSessionId": $SessionId
	    , "FlywheelSessionLabel": $SessionLabel
	    , "FlywheelSessionTags": $SessionTags
	    , "FlywheelSessionNotes": (if $SessionNotes then ($SessionNotes | sub("\\n"; " "; "gm")) else "" end)
	    , "FlywheelProjectId": $ProjectId
	    , "FlywheelAcquisitionLabel": $AcquisitionLabel
	    , "FlywheelAcquisitionType": $AcquisitionType
	    , "FlywheelAcquisitionSize": $AcquisitionSize
	    , "FlywheelAcquisitionIntent": $Intent
	    , "FlywheelAcquisitionMeasurement": $Measurement
	    , "FlywheelAcquisitionFeatures": $Features
	    , "FlywheelAcquisitionId": $AcquisitionId
	    , "AcquisitionCreatedUTC": (if $AcquisitionTimestamps then $AcquisitionTimestamps.created else "1900-01-01T00:00:00+00:00" end)
	    , "AcquisitionModifiedUTC": (if $AcquisitionTimestamps then $AcquisitionTimestamps.modified else "1900-01-01T00:00:00+00:00" end)
	    , "AcquisitionTimestampUTC": (if $AcquisitionTimestamps then $AcquisitionTimestamps.timestamp else "1900-01-01T00:00:00+00:00" end)
	    , "AshsJobDateTime": (if $AshsJobDateTime then $AshsJobDateTime else "1900-01-01T00:00:00+00:00" end)
	    , "DicomModality": .Modality
	    , "DicomInstitutionName": .InstitutionName
	    , "DicomStationName": .StationName
	    , "DicomBodyPartExamined": (if .BodyPartExamined then .BodyPartExamined else "None" end)
	    , "DicomStudyInstanceId": .StudyInstanceUID
	    , "DicomSeriesInstanceId": .SeriesInstanceUID
	    , "DicomSliceThickness": .SliceThickness
	    , "DicomPixelSpacingX": .PixelSpacing[0]
	    , "DicomPixelSpacingY": .PixelSpacing[1]

	    , "ICV": $Icv
	    , "LeftHippocampusVolume": $LeftHippocampusVolume
	    , "RightHippocampusVolume": $RightHippocampusVolume
	    , "AshsJobId": $AshsJobId
	    , "AshsJobUrl": $AshsJobUrl
	    , "AshsJobDateTime": $AshsJobDateTime

	    , "AcquisitionFileName": $AcquisitionFileName
	    , "AcquisitionFileId": $AcquisitionFileId

	    # BIDS
	    , "BidsNoBids": $BidsNoBids
	    , "BidsAcq": $BidsAcq
	    , "BidsCe": $BidsCe
	    , "BidsDir": $BidsDir
	    , "BidsTrc": $BidsTrc
	    , "BidsEcho": $BidsEcho
	    , "BidsFilename": $BidsFilename
	    , "BidsFolder": $BidsFolder
	    , "BidsIntendedFor": $BidsIntendedFor
	    , "BidsMod": $BidsMod
	    , "BidsModality": $BidsModality
	    , "BidsPath": $BidsPath
	    , "BidsRec": $BidsRec
	    , "BidsRun": $BidsRun
	    , "BidsTask": $BidsTask
	    , "BidsErrorMessage": $BidsErrorMessage
	    , "BidsIgnore": $BidsIgnore
	    , "BidsTemplate": $BidsTemplate
	    , "BidsValid": $BidsValid

	    # MRI
	    , "DicomMagneticFieldStrength": .MagneticFieldStrength
	    , "DicomSequenceName": .SequenceName
	    , "DicomRepetitionTime": .RepetitionTime
	    , "DicomEchoTime": .EchoTime
	    , "DicomEchoNumbers": .EchoNumbers
	    , "DicomFlipAngle": .FlipAngle
	    , "DicomNumberOfAverages": .NumberOfAverages
	    , "DicomAcquisitionNumber": .AcquisitionNumber
	    , "DicomSpacingBetweenSlices": .SpacingBetweenSlices

	    # PET
	    , "DicomReconstructionMethod": .ReconstructionMethod
	    , "DicomScatterCorrectionMethod": .ScatterCorrectionMethod
	    , "DicomAttenuationCorrectionMethod": .AttenuationCorrectionMethod
	    , "DicomRadiopharmaceutical": $DicomRadiopharmaceutical
	    , "DicomRadionuclide": $DicomRadionuclide
	  }
