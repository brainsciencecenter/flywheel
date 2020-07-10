import "ScannerMap" as $Scanners;
import "SubjectMap" as $Subjects;
[
	"Scanner",					# 1
	"Date",						# 2
	"Path",						# 3
	"Code",						# 4 - Subject
        "SessionID",					# 5
        "DeidentificationMethod",			# 6
	"ImageComments",				# 7
	"InstitutionName",				# 8
	"ManufacturerModelName",			# 9
	"PerformedProcedureStepDescription",		# 10
	"ProcedureStepDescription",			# 11
	"PerformingPhysicianName",			# 12
	"ReferringPhysicianName",			# 13
	"RequestingPhysician",				# 14
	"StudyComments",				# 15
	"StudyDescription"				# 16
],
(.[]
   | .label as $SessionLabel
   | ._id as $SessionID
   | .parents.subject as $SubjectID
   | .subject.code as $Code
   | .subject.label as $Label
   | .timestamp as $TimeStamp
   | if (((.acquisitions | length) > 0) and ((.acquisitions[0].files | length) > 0)) then
     .acquisitions[0].files[0]
        | .origin.id as $ScannerID
        | .info
          | [									

             if ($ScannerID | in($Scanners::Scanners[])) then			# 1
               $Scanners::Scanners[][$ScannerID]
             else
               $ScannerID
             end,

             $TimeStamp,							# 2

             if ($SubjectID | in($Subjects::Subjects[])) then			# 3
               $Subjects::Subjects[][$SubjectID] + "/" + $SessionLabel 
             else
               $SubjectID + "/" + $SessionLabel
             end,

             $Code,								# 4 - Subject
             $SessionID,							# 5

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
             .StudyDescription							# 16

             ] 
   else
     #"no acqusitions for \($SessionLabel) \($SessionID)"
     empty
   end
   ) | @csv

