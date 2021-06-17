
# echo '1' | jq -r --arg header print -L . -f ~/flywheel/bin/Non_SC_ScansforTxferFiles.json 
# jq -r -L . -f ~/flywheel/bin/Non_SC_ScansforTxferFiles.json FwGetAcquisitions.json

import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;

if ($ARGS.named | has("header")) then

([ "DateTime", "SessionId", "AcquisitionId", "AcquisitionLabel", "FilePath", "ImageType", "FileId", "ClassificationMeasurement" ]|@csv)

else
(      .parents.group as $GroupLabel 
    | .parents.session as $SessionId
    | $ProjectId2Labels::ProjectId2Labels[][.parents.project] as $ProjectLabel 
    | $SubjectId2Labels::SubjectId2Labels[][.parents.subject] as $SubjectLabel 
    | $SessionId2Labels::SessionId2Labels[][.parents.session] as $SessionLabel 
	| ._id as $AcquisitionId
	| .label as $AcquisitionLabel 
        | .timestamp as $TimeStamp
        | (if ((.files | length) > 0) then
             .files[] 
			| (if .info.ImageType then .info.ImageType | join(":") else "" end) as $ImageType 
			| (if .classification.Measurement then .classification.Measurement | join(":") else "" end) as $Measurement 
                        | (if ( .info.Modality == "MR") then
                            ([ $TimeStamp,
                               $SessionId,
			       $AcquisitionId,
			       $AcquisitionLabel,
                               "\($GroupLabel)/\($ProjectLabel)/\($SubjectLabel)/\($SessionLabel)/\($AcquisitionLabel)/files/\(.name)",
			       $ImageType,
			      ._id, 
			       $Measurement
			     ]) | @csv
                         else
			     ",,,,,,,"
                         end)
          else
	      ([ $TimeStamp, $SessionId, $AcquisitionId, $AcquisitionLabel, "\($GroupLabel)/\($ProjectLabel)/\($SubjectLabel)/\($SessionLabel)/\($AcquisitionLabel)", "", "", "" ]) | @csv
          end
	 )
	   
)
end




