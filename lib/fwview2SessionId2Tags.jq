#
# Meant to be run against the output from:
# fwview -c session -F json -p pennftdcenter/HUP6 session.{id,label,created,modified,timestamp,notes,tags} | jq .
#
# Need to produce:
# {
#    "SessionId": "Tag1:Tag2"
# }
#

[
      .data[]
    | {
          (.["session.id"]): 
          (
              if ((.["session.tags"] | length) > 0) then
	          .["session.tags"] | join(":")
	      else
	          ""
	      end
          )
      }
] | add
