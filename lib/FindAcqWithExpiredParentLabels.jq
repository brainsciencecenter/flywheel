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

    | ._id as $AcquisitionId

    | if    ($ProjectId2Labels::ProjectId2Labels[][.parents.project] | not) 
         or ($SubjectId2Labels::SubjectId2Labels[][.parents.subject] | not) 
	 or ($SessionId2Labels::SessionId2Labels[][.parents.session] | not) 
         then $AcquisitionId
	 else empty
	 end
