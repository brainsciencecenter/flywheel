# 

import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;
import "Id2SessionNotes" as $SessionId2Notes;
import "Id2SessionTimeStamps" as $SessionId2Timestamps;
import "Id2SessionTags" as $SessionId2Tags;

if $Header then
      (["ProjectLabel","ProjectId","SubjectLabel","SubjectId","SessionLabel","SessionId","AcquisitionLabel","AcquisitionId","FileName","FileId","FileSize","FileDeIdProfile","FilePiiStatus","MetadataDeIdProfile","MetadataPiiStatus"]|@csv)

# "pmc_exvivo","5c37ac6d1de80b00198acd4a","HNL_28_17L","5c5ed3c5d23583002ea9f9fa","9.4TMTL_HNL_28_17_20180604","5c5ed3c5d23583002ca9fadb","2018-06-04 13:57:51","5c5ed3c5d23583002fa9fef7","2018-06-04 13_57_51.dicom.zip","622fbd6cfa62e8ba6cd449d5",53252046,"Penn_BSC_profile_v3.0","PiiFileInfoFields:ReferringPhysicianName","CR common deidentification v001 - site-wide","PiiMetadataFields:ReferringPhysicianName"
#
else
#
#
# Strip out the DeidentificationMethod field
# We're reporting the deid profile name independently from the PiiFields
#
      ($DeIdProfileNullFields | to_entries | [ .[] | select(.key != "DeidentificationMethod") ] | from_entries ) as $DeIdProfileNullFields 

    | .parents.group as $GroupLabel 
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

    | .metadata as $Metadata

    | .files[]
   
        | .name as $AcquisitionFileName
        | .file_id as $AcquisitionFileId
        | .size as $FileSize
        | .info
        |
            [
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
                if .DeidentificationMethod then
		  if ( .DeidentificationMethod | type ) == "string" then
			.DeidentificationMethod
		  else
			.DeidentificationMethod | join(":")
		  end
	        else
		  "NoFileDeidentificationProfile"
		end,
    

#
# Deal with the wonky metadata field in flywheel acquisitions
#
		(to_entries
		  | map(
		         if (.key | in($DeIdProfileNullFields)) then
			     if (.value) then
			          if (.value != $DeIdProfileNullFields[.key]) then
				      .key
				  else
				      empty
         			  end
		 	     else
			          empty
		             end
	                 else
			     empty
		         end
		    )
                  | if (length > 0) then ("PiiFileInfoFields:" + (sort | join(":"))) else "FileInfoClean" end
		)
            ] +
            [
               if ($Metadata) then
	       	  $Metadata 
	          |   if (.DeidentificationMethod) then
			if ( .DeidentificationMethod | type) == "string" then
			     .DeidentificationMethod
			else
			     .DeidentificationMethod | join(":")
			end
		      else
			"NoMetadataDeidentificationProfile"
		      end,

#	               (   to_entries 
#	      	         | map(if ((.key) | in($DeIdProfileNullFields)) and .value != null and .value != "" then .key else empty end) 
#		         | length as $Length
#		         | if (length > 0) then ("PiiMetadataFields:" + (sort | join(":"))) else "MetadataClean", $Length end
#                      )
		(to_entries
		  | map(
		         if (.key | in($DeIdProfileNullFields)) then
			     if (.value) then
			          if (.value != $DeIdProfileNullFields[.key]) then
				      .key
				  else
				      empty
         			  end
		 	     else
			          empty
		             end
	                 else
			     empty
		         end
		    )
                  | if (length > 0) then ("PiiMetadataFields:" + (sort | join(":"))) else "MetadataClean" end
		)


                  else
                      "MetadataNull",
		      "MetadataClean" 
                  end
            ]
 | @csv

end
