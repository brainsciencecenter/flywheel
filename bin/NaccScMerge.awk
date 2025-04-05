#!/usr/bin/awk

BEGIN {
	PrevKey = "";
	PrevVal = "";
	FS = ",";
}

/.+/	{
		# $5 is the Session Id number.  $9 is the modality.  Want the first MR nifti for each modality within a session
		CurKey = $5 ":" $9;
		CurVal = $0;
		
		if (($11 == "\"PT\"") || (PrevKey != CurKey)) {
			if (length(PrevKey) > 0) {
				print(PrevVal);
			}
			PrevKey = CurKey;
			PrevVal = CurVal;
		}
#		else {
#			print("Stay", $11, PrevKey, CurKey, PrevVal);
#		}
	}
END	{
		if (length(PrevKey) > 0) {
			print(PrevVal);
		}
	}

