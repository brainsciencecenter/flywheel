include "FwLib";

container2Timestamps(.) as $Timestamps
| select(
	      # verify the Id is in the active Acquisition list
              (._id | in($AcquisitionId2TimestampsActive[]))

	      # make sure the .timestamp/.modified matches
	  and ($Timestamps == $AcquisitionId2TimestampsActive[][._id])

	      # Returns true if *All* the parent and collection ids are in the ids dictionary
	  and (select([.parents[] | select(.)] + .collections | map(in($Ids2Labels[]) ) | all))
	)


