
#  echo '"null"' | jq -n  -r  -L . -f ~/flywheel/bin/Non_SC_ScansforTxferFiles.jq ; jq -r  -L . -f ~/flywheel/bin/Non_SC_ScansforTxferFiles.jq CachedFwGetAcquisitions.json )  > NACC-SC-Acquisitions.csv 

import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;
import "Id2SessionTimeStamps" as $SessionId2TimeStamps;

if (. == null) then

([ "DateTime", "AcquisitionId", "AcquisitionLabel", "SessionId", "SessionDateTime", "FilePath", "Modality", "ImageType", "FileId", "ClassificationMeasurement" ]|@csv)

else
(
      ._id as $AcquisitionId
    | .label as $AcquisitionLabel 
    | .timestamp as $TimeStamp
    | .parents.group as $GroupLabel 
    | .parents.session as $SessionId
    | $ProjectId2Labels::ProjectId2Labels[][.parents.project] as $ProjectLabel 
    | $SubjectId2Labels::SubjectId2Labels[][.parents.subject] as $SubjectLabel 
    | $SessionId2Labels::SessionId2Labels[][.parents.session] as $SessionLabel 
    | $SessionId2TimeStamps::SessionId2TimeStamps[][.parents.session] as $SessionTimeStamp
        | (if ((.files | length) > 0) then
             .files[] 
			| (if ((.info.ImageType|type) == "array") then (.info.ImageType | join(":")) else .info.ImageType end) as $ImageType 
			| (if .classification.Measurement then .classification.Measurement | join(":") else "" end) as $Measurement 
                        |   ([ 
			       $TimeStamp,
			       $AcquisitionId,
			       $AcquisitionLabel,
                               $SessionId,
			       $SessionTimeStamp,
                               "\($GroupLabel)/\($ProjectLabel)/\($SubjectLabel)/\($SessionLabel)/\($AcquisitionLabel)/files/\(.name)",
			       .info.Modality,
			       $ImageType,
			      ._id, 
			       $Measurement
			     ]) | @csv
          else
	      ([ $TimeStamp, $AcquisitionId, $AcquisitionLabel, $SessionId, $SessionTimeStamp, "\($GroupLabel)/\($ProjectLabel)/\($SubjectLabel)/\($SessionLabel)/\($AcquisitionLabel)", "", "", "", "" ]) | @csv
          end
	 )
	   
)
end




