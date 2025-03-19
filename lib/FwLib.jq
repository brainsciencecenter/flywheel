def getLastPicslBioMarkersDateTime(p): (
      if ((p) and ((p) | [ keys[] | test("ASHS-") ] | any) )
      then
            (p)
	  | to_entries
	  | [ .[] | select(.key | test("ASHS-")) | .value.JobInfo.JobDateTime ]
	  | sort
	  | last
      else
          ""
      end
) ;

def container2Timestamps(c): (
      c
    | {
          "created": (if (.created) then .created else "" end)
	, "modified": (if (.modified) then .modified else "" end)
	,  "timestamp": (if .timestamp then .timestamp else "" end)
#	, "AshsJobDateTime": getLastPicslBioMarkersDateTime(.info.PICSL_sMRI_biomarkers)
       }
) ;

def fwThing2FwPath(t; Id2Label): (
     ( if (t | has("name")) then ("files/" + t.name) else (t.label) end) as $Label
   | [ t.parents[] | select(.) ] | map(Id2Label[][.])| join("/") + "/" + $Label | sub("//"; "/")
) ;

#
# Returns the datetime the session was scanned
#
def sessionScanDateTime(s): (
    .timestamp
) ;

def from2Time(f;t): (sub("\\..*";"") | strptime(f) | strftime(t)) ;

def toObject: if ((. | type) == "array") then .[] else . end ;

