import "ScannerMap" as $Scanners;
import "Id2ProjectLabels" as $Id2ProjectLabels;
import "Id2SubjectLabels" as $Id2SubjectLabels;
import "Id2SessionLabels" as $Id2SessionLabels;
import "Id2SessionTimeStamps" as $Id2SessionTimeStamps;

# [
# 	"Scanner",					# 1
# 	"Date",						# 2
# 	"Path",						# 3
# 	"Code",						# 4 - Subject
#         "SessionID",					# 5
#         "DeidentificationMethod",			# 6
# 	"ImageComments",				# 7
# 	"InstitutionName",				# 8
# 	"ManufacturerModelName",			# 9
# 	"PerformedProcedureStepDescription",		# 10
# 	"ProcedureStepDescription",			# 11
# 	"PerformingPhysicianName",			# 12
# 	"ReferringPhysicianName",			# 13
# 	"RequestingPhysician",				# 14
# 	"StudyComments",				# 15
# 	"StudyDescription",				# 16
# 	"Manufacturer",					# 17
# 	"MagneticFieldStrength"				# 18
# 
# ],
(    
      .parents.group as $GroupLabel 
    | .parents.session as $SessionId
    | .parents.subject as $SubjectId
    | $Id2ProjectLabels::Id2ProjectLabels[][.parents.project] as $ProjectLabel 
    | $Id2SubjectLabels::Id2SubjectLabels[][.parents.subject] as $SubjectLabel 
    | $Id2SessionLabels::Id2SessionLabels[][.parents.session] as $SessionLabel 
    | $Id2SessionTimeStamps::Id2SessionTimeStamps[][.parents.session] as $SessionTimeStamp
    | .files[0]

        | .origin.id as $ScannerId
        | .info
          | [									

             if ($ScannerId | in($Scanners::Scanners[])) then			# 1
               $Scanners::Scanners[][$ScannerId]
             else
               $ScannerId
             end,

             $SessionTimeStamp,							# 2

             if ($SubjectId | in($Id2SubjectLabels::Id2SubjectLabels[])) then			# 3
               $Id2SubjectLabels::Id2SubjectLabels[][$SubjectId] + "/" + $SessionLabel 
             else
               $SubjectId + "/" + $SessionLabel
             end,

             $SubjectLabel,								# 4 - Subject
             $SessionId,							# 5

             if ((.DeidentificationMethod | type) == "array") then		# 6
               .DeidentificationMethod[0]
             else
                .DeidentificationMethod
             end,
 
             .ImageComments,							# 7
             .InstitutionName,							# 8
             .ManufacturerModelName,						# 9
             .PerformedProcedureStepDescription,				# 10
             .PerformingPhysicianName,						# 11
             .ProcedureStepDescription,						# 12
             .ReferringPhysicianName,						# 13
             .RequestingPhysician,						# 14
             .StudyComments,							# 15
             .StudyDescription,							# 16
	     .Manufacturer,							# 17
	     .MagneticFieldStrength						# 18

             ] 
   ) | @csv

