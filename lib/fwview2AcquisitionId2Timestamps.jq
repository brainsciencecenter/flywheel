#
#
# Looking for output like:
# {
#   "65e5f5df87f4dda8fc85dff0": {
#     "created": "2024-03-04T16:25:03.615000+00:00",
#     "modified": "2024-07-09T21:19:23.894000+00:00",
#     "timestamp": "2016-06-21 15:24:43+00:00",
#   }
# }
# {
#   "65e5f617fcd3efeeecb3d492": {
#     "created": "2024-03-04T16:25:59.098000+00:00",
#     "modified": "2024-07-09T21:19:17.409000+00:00",
#     "timestamp": "2016-06-21 16:10:28+00:00",
#   }
# }
# {
#   "65eb4fb8e71411895685e1bf": {
#     "created": "2024-03-08T17:49:44.269000+00:00",
#     "modified": "2024-08-06T15:52:53.443000+00:00",
#     "timestamp": "2024-08-06 15:52:50.341000+00:00",
#   }
# }

def fwCanonicalTimestamp(t): (
    t | sub("\\.[0-9]{6}"; "") | sub(" "; "T")
) ;
[
  .data[]
| {
     (.["acquisition.id"]): {
          "created": (if (.["acquisition.created"]) then fwCanonicalTimestamp(.["acquisition.created"]) else "" end)
        , "modified": (if (.["acquisition.modified"]) then fwCanonicalTimestamp(.["acquisition.modified"]) else "" end)
        , "timestamp": (if (.["acquisition.timestamp"]) then fwCanonicalTimestamp(.["acquisition.timestamp"]) else "" end)
     }
   } 
] | add
