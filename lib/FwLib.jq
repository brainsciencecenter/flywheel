#

def abs:
  if . < 0 then -. else . end;

def zeros($n):
  reduce range(0; $n) as $i (""; . + "0");

#
# formats a number as a ndecimal string
# 
# jq -n -L ../lib 'include "FwLib"; 567.1234 | scale(2)'
# 567.12
#
# Handles negative numbers
# Pads leading zeros in case of -0.08333999999999997
#
def scale($d):
  (. < 0) as $neg
  | ((abs * ($d|exp10) | round | tostring) as $n
     | (zeros($d) + $n) as $p
     | ($p[($p|length - (if ($n|length) > $d then ($n|length) else $d end)):])) as $n
  | (($n[:-$d]) + "." + ($n[-$d:])) as $s
  | (if $s[0:1] == "." then "0" + $s else $s end)
  | if $neg then "-" + . else . end;

def formatIlabNote: (
           (.BscChargePerTbPerYear / 12) as $PricePerTbPerMonth
        |
          .FundName
        + " ("
        + .BenNumber
        + ") - "
        + .ProjectPath
        +  " - "
        + (.TotalTerabytesUsed | scale(4) | tostring)
        + "TB * $"
        + ($PricePerTbPerMonth | tostring)
        + "/Tb/M = $"
        + ( .BscBill | scale(2) | tostring)
        + " * "
        + ((.AllocationPercent / 100.0 | scale(2)) | tostring)
        + " = "
 );

#
# Returns true if the string ends in 'CLARiTI'.  Case is important.
#
def isClaritiSession(SessionLabel): (
    SessionLabel | test("CLARiTI$")
);

def createdDate(Session): (
    .CreatedDate | sub("T.*$"; "") 
); 

def hasAcquisition(AcquisitionLabel): (
    [ .Acquisitions[].AcquisitionLabel ] | any(. | test(AcquisitionLabel))
);

def markForTagging(AcquisitionLabel;Tag): (
      .Acquisitions[] | select(.AcquisitionLabel | test(AcquisitionLabel))
    | [ .Files[].FileName ] as $FileNames
    | [ .Files[] | select(.FileType == "dicom" or .FileType == "nifti") ]
       | sort_by(.FileType)[-1] as $FileToTag
           | $FileToTag
           | ((.FileType == "nifti") | not) as $RunDcm2Niix
           | {
	           "FileIdToTag": .FileId
		 , "FileType": .FileType
		 , "Tag": Tag
		 , "RunDcm2niix": $RunDcm2Niix
		 , "FilePath": .FilePath
		 , "FileNames": $FileNames
	     }
);

def backedupTotalTerabytesUsed(TerabytesUsed): (
    (
	TerabytesUsed
      | .BackedupGPFS + .Backedupbscfiles1 + .Backedupbscfiles2 + .Backedupbscfiles3
    )
) ;

def nonBackedupTotalTerabytesUsed(TerabytesUsed): (
    (
          TerabytesUsed
  	| .NotBackedupGPFS + .NotBackedupbscfiles1 + .NotBackedupbscfiles2 + .NotBackedupbscfiles3
    )
) ;

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

def jobId2JobUrl(jobid): (
    "https://upenn.flywheel.io/#/jobs/" + jobid
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

def pmbmHarpIcvMetrics(pmbm): (
      {
          "LeftHippocampusVolume": pmbmLeftHippocampusVolume(.)
        , "RightHippocampusVolume": pmbmRightHippocampusVolume(.)
        , "ICV": pmbmIcv(.)
        , "JobId": pmbmJobId(.)
      }    
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

