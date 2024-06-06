    (
        if (.timestamp > .modified) then
            .timestamp 
        else
            .modified 
        end
    ) as $Timestamp
| select(
	      # verify the Id is in the active Acquisition list
              (._id | in($AcquisitionId2Timestamps[]))

	      # make sure the .timestamp/.modified matches
	  and ($Timestamp == $AcquisitionId2Timestamps[][._id])

	      # Returns true if *All* the parent and collection ids are in the ids dictionary
	  and (select([.parents[] | select(.)] + .collections | map(in($Ids2Labels[]) ) | all))
	)

