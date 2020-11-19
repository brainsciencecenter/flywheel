(.[]
   | .label as $SessionLabel
   | ._id as $SessionID
   | .parents.subject as $SubjectID
   | .parents.project as $ProjectID
   | .subject.code as $Code
   | .subject.label as $SubjectLabel
   | .timestamp as $TimeStamp
   | if (((.acquisitions | length) > 0) and ((.acquisitions[0].files | length) > 0)) then
     .acquisitions[0].label as $AcquisitionLabel
     | .acquisitions[0]._id as $AcquisitionID
     | .acquisitions[0].files[0]        # *** can it not be in file 0 or acquisition 0?
        | .origin.id as $ScannerID
        | .info
          | [									

             $SubjectLabel, # *** this should be the indd formatted version (\d{6}([\._\-x]\d{2})?)
             $SubjectLabel,
             $TimeStamp,
             "https://upenn.flywheel.io/#/projects/\($ProjectID)/sessions/\($SessionID)?tab=data",
             $SessionID,
             $ProjectID,
	     $AcquisitionLabel,
             (.Intent.classification | join(";")) // "None",       # FlywheelAcquisitionIntent => ';'.join(Intent.classification[])
             (.Measurement.classification | join(";")) // "None",  # FlywheelAcquisitionMeasurement => ';'.join(Measurement.classification[])
             (.Features.classification | join(";")) // "None",     # FlywheelAcquisitionFeatures => ';'.join(Features.classification[])
	     $AcquisitionID,
	     .Modality,
	     .InstitutionName,
	     .StationName,
	     .BodyPartExamined // "None",
	     .StudyInstanceUID,
	     .SeriesInstanceUID,
	     .SliceThickness,  # needs to be in %.1f
	     .PixelSpacing[0], # needs to be in %.1f
	     .PixelSpacing[1], # needs to be in %.1f
	     # MR
	     .MagneticFieldStrength,
	     .SequenceName,
	     .RepetitionTime,
	     .EchoTime,
	     .EchoNumbers,
	     .FlipAngle,
	     .NumberOfAverages,
	     .AcquisitionNumber,
	     .SpacingBetweenSlices,

	     # PT
	     .ReconstructionMethod // "None",
	     .ScatterCorrectionMethod // "None",
	     .AttenuationCorrectionMethod // "None",
	     .RadiopharmaceuticalInformationSequence.RadionuclideCodeSequence.Radiopharmaceutical // "None",
	     .RadiopharmaceuticalInformationSequence.RadionuclideCodeSequence.CodeMeaning // "None",

	     ""
             ] 
   else
     #"no acqusitions for \($SessionLabel) \($SessionID)"
     empty
   end
   ) | @csv

#             $Code,								# 4 - Subject
#             $SessionID,							# 5
#
#             if ((.DeidentificationMethod | type) == "array") then		# 6
#               .DeidentificationMethod[0]
#             else
#                .DeidentificationMethod
#             end,
# 
#             .ImageComments,							# 7
#             .InstitutionName,							# 8
#             .ManufacturerModelName,						# 9
#             .PerformedProcedureStepDescription,				# 10
#             .PerformingPhysicianName,						# 11
#             .ProcedureStepDescription,						# 12
#             .ReferringPhysicianName,						# 13
#             .RequestingPhysician,						# 14
#             .StudyComments,							# 15
#             .StudyDescription							# 16
#