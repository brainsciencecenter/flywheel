#
# fwview -c $container -p 65e5f43074ebb37c174510c8 $container.id $container.created $container.modified $container.timestamp $container.info.PICSL_sMRI_biomarkers.ASHS-{HarP,ICV,PMC-T1,PMC,ABC-3T,ABC-7T,Magdeburg,Princeton,Utrect}.JobInfo.JobDateTime | csvjson -y 0 --stream | jq --arg container $container -f fwview2IdNDateTimes.jq
#
# Looking for output like:
# {
#   "65e5f5df87f4dda8fc85dff0": {
#     "created": "2024-03-04T16:25:03.615000+00:00",
#     "modified": "2024-07-09T21:19:23.894000+00:00",
#     "timestamp": "2016-06-21 15:24:43+00:00",
#     "AshsJobDateTime": ""
#   }
# }
# {
#   "65e5f617fcd3efeeecb3d492": {
#     "created": "2024-03-04T16:25:59.098000+00:00",
#     "modified": "2024-07-09T21:19:17.409000+00:00",
#     "timestamp": "2016-06-21 16:10:28+00:00",
#     "AshsJobDateTime": ""
#   }
# }
# {
#   "65eb4fb8e71411895685e1bf": {
#     "created": "2024-03-08T17:49:44.269000+00:00",
#     "modified": "2024-08-06T15:52:53.443000+00:00",
#     "timestamp": "2024-08-06 15:52:50.341000+00:00",
#     "AshsJobDateTime": "2024-08-06T15:52:22+00:00"
#   }
# }

#
# this finds the most recent Atlas JobDateTime from the possible atlases and stores it as $AshsJobDateTime
# 
  (to_entries | [ .[] | select(.key | test($container+".info.PICSL_sMRI_biomarkers.ASHS.*.JobInfo.JobDateTime") ) | .value ] | sort | last) as $AshsJobDateTime

# build the timestamp dict with $AshsJobDateTime if there is a non-null
| {
     (.[$container+".id"]): {
          "created": (if (.[$container+".created"]) then .[$container+".created"] else "" end)
        , "modified": (if (.[$container+".modified"]) then .[$container+".modified"] else "" end)
        , "timestamp": (if (.[$container+".timestamp"]) then .[$container+".timestamp"] else "" end)
        , "AshsJobDateTime": (if ($AshsJobDateTime) then $AshsJobDateTime else "" end)
     }
   } 
