#
# Meant to be run against the output from:
# fwview -c session -F json -p pennftdcenter/HUP6 session.{id,label,created,modified,timestamp,notes,tags} | jq .
#
# Need to produce:
# {
#    "SessionId": "Note2"
# }
#
# Occasionally, notes contains carriage returns and confounding characters
#

[
      .data[]
    | {
          (.["session.id"]): 
	  (
	      if ((.["session.notes"] | length) > 0) then
                  (.["session.notes"] | .[].text | sub("[\n\r]"; " ") )
              else
	          ""
	      end
          )
      }
] | add
