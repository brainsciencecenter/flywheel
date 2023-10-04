# 


import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;
import "Id2SessionNotes" as $SessionId2Notes;
import "Id2SessionTimeStamps" as $SessionId2Timestamps;
import "Id2SessionTags" as $SessionId2Tags;

      .parents.group as $GroupLabel 
    | .parents.project as $ProjectId
    | .parents.subject as $SubjectId
    | .parents.session as $SessionId

    | $ProjectId2Labels::ProjectId2Labels[][.parents.project] as $ProjectLabel 
    | $SubjectId2Labels::SubjectId2Labels[][.parents.subject] as $SubjectLabel 
    | $SessionId2Labels::SessionId2Labels[][.parents.session] as $SessionLabel 
    | $SessionId2Notes::SessionId2Notes[][.parents.session] as $SessionNotes
    | $SessionId2Timestamps::SessionId2Timestamps[][.parents.session] as $SessionTimeStamp
    | $SessionId2Tags::SessionId2Tags[][$SessionId] as $SessionTags

    | ._id as $AcquisitionId
    | .label as $AcquisitionLabel
    | (if (.timestamp) then .timestamp else .created end) as $TimeStamp

    | .files
    | .[]

      | .name as $AcquisitionFileName
      | .file_id as $AcquisitionFileId
      | .size as $FileSize
      | .info

      | [
	    $ProjectLabel,
	    $ProjectId,
	    $SubjectLabel,
      	    $SubjectId,
	    $SessionLabel,
	    $SessionId,
	    $AcquisitionLabel,
	    $AcquisitionId,
	    $AcquisitionFileName,
	    $AcquisitionFileId,
	    $FileSize,

	    if .DeidentificationMethod then .DeidentificationMethod else "NoDeidentificationProfile" end,

	    (to_entries 
	      	  | map(if ((.key) | in($PennBscDeIdProfileNullFieldsJson)) and .value != null and .value != "" then .key else empty end) 
		  | if length > 0 then ("PiiFields:" + (sort | join(":"))) else "Clean" end
            )

	  ]
 | @csv
