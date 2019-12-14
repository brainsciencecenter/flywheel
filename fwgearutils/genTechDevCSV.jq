import "ScannerMap" as $Scanners;
import "SubjectMap" as $Subjects;
.[]
   | .label as $SessionLabel
   | .parents.subject as $SubjectID
   | .subject.code as $Code
   | .subject.label as $Label
   | .created as $CreationDate
   | .acquisitions[0].files[0]
      | .origin.id as $ScannerID
      | .info
        | [
             $Scanners::Scanners[][$ScannerID],
             $CreationDate,
             ($Subjects::Subjects[][$SubjectID] + "/" + $SessionLabel),
             $Code,
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
           ] | @csv
