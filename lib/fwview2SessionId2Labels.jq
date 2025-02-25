#
# Meant to be run against the output from:
# fwview -c session -F json -p pennftdcenter/HUP6 session.{id,label,created,modified,timestamp,notes,tags} | jq .
#
# Need to produce:
# { "SessionId": "Label" }
# to feed to
# jq -s 'add'
#

      .data[]
    | {
          (.["session.id"]): 
          (
	      .["session.label"]
          )
      }
