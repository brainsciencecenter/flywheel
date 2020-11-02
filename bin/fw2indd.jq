import "ScannerMap" as $Scanners;
import "SubjectMap" as $Subjects;

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
     | .acquisitions[0].files[0]
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
             .FlywheelAcquisitionIntent // "None",
             .FlywheelAcquisitionMeasurement // "None",
             .FlywheelAcquisitionFeatures // "None",
	     $AcquisitionID,
	     .Modality,
	     .InstitutionName,
	     .StationName,
	     .BodyPartExamined // "None",
	     .StudyInstanceUID,
	     .SeriesInstanceUID,
	     .SliceThickness,
	     .PixelSpacingX,
	     .PixelSpacingY,

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