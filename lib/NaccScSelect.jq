
#
# To select acquisition files for WashUStl
# MRI: T1, T2 or FLAIR nifti files
# PET: Any dicom -- make sure they get de-ided before they go out
# 
# We don't care about pixel spacing since we're going to give them all the nifti files, no matter what the pixel spacing is
#
# jq -r --slurpfile Id2Labels dwolklab/NACC-SC/Id2Labels.json -f ~/flywheel/lib/NaccScSelect.jq dwolklab-NACC-SC-CachedFwAcquisitions.json | (LANG=C sort -u) | awk -f ~/flywheel/bin/NaccScMerge.awk
# 
    (.parents.group) as $GroupLabel
  | (.parents.project) as $ProjectId
  | ($Id2Labels[][$ProjectId]) as $ProjectLabel
  | (.parents.subject) as $SubjectId
  | ($Id2Labels[][.parents.subject]) as $SubjectLabel
  | (.parents.session) as $SessionId
  | ($Id2Labels[][.parents.session]) as $SessionLabel
  | (._id) as $AcquisitionId
  | (.label) as $AcquisitionLabel
  | .files[]
  |   select(
                    (
                          ( .info.Modality == "PT" and .type == "dicom" )
				# LOCALIZER seems to be the only string type and we're filtering out LOACALIZER PET scans
                      and ( (.info.ImageType | type) == "array" )
                      and ( ($AcquisitionLabel | test("BR.DY.CTAC")) )
                    )
                 or 
                     (
                          ( .info.Modality == "MR" and .type == "nifti")
                      and ( $AcquisitionLabel | test("(T1)|(T2)|(FLAIR)") )
                      and .classification
                      and (     (.classification.Measurement and (.classification.Measurement | any(. == "T1" or . == "T2" )))
                             or (.classification.Features and (.classification.Features | any(. == "FLAIR")))
                          )
                     )
             )
      | 
             (
                 (
                     if (.classification and .classification.Measurement) then .classification.Measurement else [] end
                   + if (.classification and .classification.Features) then .classification.Features else [] end
                 ) | sort | join(":")
             ) as $ClassificationMeasurementFeatures
      |
             (
               if (  ( .info.ImageType | type) == "array" ) then
                  ( .info.ImageType | sort | join(":") )
               else
                  .info.ImageType
               end
             ) as $ImageType
      |
             (
	       # Lower sorts first
               if (  ( .info.ImageType | type) == "array" ) then
                  if ( .info.ImageType | any(. == "ND") ) then
                         1
                  else
                         2
                  end
               else
                  9
               end
             ) as $Weight
       |     (
       	        if (.tags and ((.tags | length) > 0)) then (.tags | sort | join(":")) else "" end
             ) as $FileTags
       |
          [
	       $GroupLabel
             , $ProjectLabel
#             , $ProjectId
             , $SubjectLabel
#             , $SubjectId
             , $SessionLabel
             , $SessionId

             , .info.PixelSpacing[0]
             , .info.PixelSpacing[1]
             , $Weight
             , $ClassificationMeasurementFeatures
             , $AcquisitionLabel
             , $ImageType
             , .info.Modality
         	# *** info.ImageType is a string for LOCALIZER .info.ImageType, but an array for ND type.

             , $AcquisitionId
             , .type
             , .name
	     , $FileTags
             , .file_id
           ]
    | @csv
