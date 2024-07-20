def container2Timestamps(c): (c | {"created": (if (.created) then .created else "" end), "modified": (if (.modified) then .modified else "" end),  "timestamp": (if .timestamp then .timestamp else "" end), "AshsJobDate": (if (.info.PICSL_sMRI_biomarkers.DateTime) then .info.PICSL_sMRI_biomarkers.DateTime else "" end) } ) ;

def from2Time(f;t): (sub("\\..*";"") | strptime(f) | strftime(t)) ;

def toObject: if ((. | type) == "array") then .[] else . end ;
