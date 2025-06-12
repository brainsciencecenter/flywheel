#

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

# returns two digit age.  Seconds in Year is roughly right
def dobToAge(dob;scandate): (
    (365 * 24 * 60 * 62) as $SecondsInYear
  | (scandate | strptime("%Y-%m-%d") | mktime) as $CurrentSeconds
  | (dob | strptime("%m-%d-%Y") | mktime) as $DobSeconds
  | ($CurrentSeconds - $DobSeconds) / $SecondsInYear | . * 100 | round / 100
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

def pmbmIcv(pmbm): (
       if (pmbm["ASHS-ICV"].Metrics.left_bootstrap_corr_nogray_volumes_txt.ICV) then
           pmbm["ASHS-ICV"].Metrics.left_bootstrap_corr_nogray_volumes_txt.ICV
       else
           if (pmbm.ICV) then
	       pmbm.ICV
           else
	       "None"
	   end
       end
) ;

def pmbmLeftHippocampusVolume(pmbm): (
       if (pmbm["ASHS-HarP"].Metrics.left_bootstrap_corr_nogray_volumes_txt.Hippocampus) then
           pmbm["ASHS-HarP"].Metrics.left_bootstrap_corr_nogray_volumes_txt.Hippocampus
       else
           if (pmbm.LeftHippocampusVolume) then
	       pmbm.LeftHippocampusVolume
	   else
	       "None"
	   end
       end
) ;

def pmbmRightHippocampusVolume(pmbm): (
       if (pmbm["ASHS-HarP"].Metrics.right_bootstrap_corr_nogray_volumes_txt.Hippocampus) then
           pmbm["ASHS-HarP"].Metrics.right_bootstrap_corr_nogray_volumes_txt.Hippocampus
       else
           if (pmbm.RightHippocampusVolume) then
	       pmbm.RightHippocampusVolume
	   else
	       "None"
	   end
       end
) ;

def pmbmHasHippocampusVolume(pmbm): (
      pmbmLeftHippocampusVolume(pmbm) as $LeftHippocampusVolume
    | pmbmRightHippocampusVolume(pmbm) as $RightHippocampusVolume
    | (
            ($LeftHippocampusVolume and $LeftHippocampusVolume != "None")
	and ($RightHippocampusVolume and $RightHippocampusVolume != "None")
      )
) ;

def pmbmHasIcv(pmbm): (
      pmbmIcv(pmbm) as $Icv
    | ($Icv and ($Icv != "None"))
) ;

def pmbmJobId(pmbm): (    
       if (pmbm) then
         [ pmbm | to_entries[] | select(.key == "ASHS-ICV" or .key == "ASHS-HarP") | .value.JobInfo ] | sort_by(.JobDateTime, .JobId) | last | .JobId
       else
         "None"
       end
) ;

def pmbmHasJobId(pmbm): (    
          pmbmJobId(pmbm) as $JobId
       | ($JobId and ($JobId != "None"))
) ;

def pmbmJobDateTime(pmbm): (    
       if (pmbm) then
         [ pmbm | to_entries[] | select(.key == "ASHS-ICV" or .key == "ASHS-HarP") | .value.JobInfo ] | sort_by(.JobDateTime, .JobId) | last | .JobDateTime
       else
          "None"
       end
) ; 

def from2Time(f;t): (sub("\\..*";"") | strptime(f) | strftime(t)) ;

def toObject: if ((. | type) == "array") then .[] else . end ;

