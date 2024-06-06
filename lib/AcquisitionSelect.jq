    (
        if (.timestamp > .modified) then
            .timestamp 
        else
            .modified 
        end
    ) as $Timestamp
| select(
	      # verify the Id is in the active Acquisition list
              (._id | in($AcquisitionId2TimestampsActive[]))

	      # make sure the .timestamp/.modified matches
	  and ($Timestamp == $AcquisitionId2TimestampsActive[][._id])

	      # Returns true if *All* the parent and collection ids are in the ids dictionary
	  and (select([.parents[] | select(.)] + .collections | map(in($Ids2Labels[]) ) | all))
	)

