import "ScannerMap" as $Scanners;
import "SubjectMap" as $Subjects;
[
	"Scanner",
	"Date",
	"Path",
	"Subject",
	"FWUID",
	"Code",
	"ImageComments",
	"InstitutionName",
	"ManufacturerModelName",
	"PerformedProcedureStepDescription",
	"PerformingPhysicianName",
	"ReferringPhysicianName",
	"StudyComments",
	"StudyDescription"
],
(.[]
   | .label as $SessionLabel
   | ._id as $SessionID
   | .parents.subject as $SubjectID
   | .subject.code as $Code
   | .subject.label as $Label
   | .created as $CreationDate
   | if (.acquisitions | length) > 0 then
     .acquisitions[0].files[0]
        | .origin.id as $ScannerID
        | .info
          | [

             if ($ScannerID | in($Scanners::Scanners[])) then
               $Scanners::Scanners[][$ScannerID]
             else
               $ScannerID
             end,

             $CreationDate,

             if ($SubjectID | in($Subjects::Subjects[])) then
               $Subjects::Subjects[][$SubjectID] + "/" + $SessionLabel 
             else
               $SubjectID + "/" + $SessionLabel
             end,

             $Code,
             $SessionID,
             .ImageComments,
             .InstitutionName,
             .ManufacturerModelName,
             .PerformedProcedureStepDescription,
             .PerformingPhysicianName,
             .ProcedureStepDescription,
             .ReferringPhysicianName,
             .RequestingPhysician,
             .StudyComments,
             .StudyDescription

             ] 
   else
     #"no acqusitions for \($SessionLabel) \($SessionID)"
     empty
   end
   ) | @csv

