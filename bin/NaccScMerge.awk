#!/usr/bin/awk

BEGIN {
	PrevKey = "";
	PrevVal = "";
	FS = ",";

	Debug = 0
}

/.+/	{
		# $5 is the Session Id number.  $12 is the modality (MR|PT).  Want the first MR nifti for each modality within a session
		CurVal = $0;
                SessionId = $5
		Modality = $12

		CurKey = SessionId ":" Modality;
		
		if (Debug) {
		    print("Curkey =",CurKey, "Prevkey =",PrevKey);
		}

		if ((Modality == "\"MR\"") || (PrevKey != CurKey)) {
		    if (Debug) {
			print ("Ready to update", "Curkey =",CurKey, "Prevkey =",PrevKey, "Modality = ",Modality);
		    }
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

