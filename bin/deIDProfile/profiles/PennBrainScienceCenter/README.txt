de-id_upenn_Penn_BSC_profile_v1.0_20190906A.yaml is the profile used by the reaper on
HUP6.

Example use with the CLI:

  fw import dicom \
    --subject subjectID \
    --session sessionID \
    --output-folder /path/to/testOutput \
    --profile de-id_upenn_Penn_BSC_profile_v1.0_20190906A.yaml \
    /path/to/dicomDir aGroup aProject


You can examine dicom images after a dry run with gdcmscanner.

  gdcmscanner -p -r -d  /path/to/flywheel/data -t 0012,0063 | more

You should get output like this:

done retrieving file list <NUMBER OF FILES> files found.
Values:
Penn_BSC_profile_v1.0 
Mapping:
Filename: /path/to/some/file.dcm (could be read)
(0012,0063) -> [Penn_BSC_profile_v1.0 ]


Each file should have "Penn_BSC_profile_v1.0" for tag
(0012,0063). This tells you that the de-identification profile was
applied to each file.  

If you want to check the full set of tags to empty, you can do

  gdcmscanner -p -r -d /path/to/flywheel/data \
  -t 0008,0050 -t 0008,0090 -t 0008,0092 -t 0008,0094 -t 0008,0096 \
  -t 0008,009c -t 0008,009d -t 0008,1048 -t 0008,1049 -t 0008,1050 \
  -t 0008,1052 -t 0008,1060 -t 0008,1062 -t 0008,1080 -t 0010,0010 \
  -t 0010,0020 -t 0010,1030 -t 0010,0021 -t 0010,0030 -t 0010,0032 \
  -t 0010,0033 -t 0010,0034 -t 0010,0050 -t 0010,0101 -t 0010,1000 \
  -t 0010,1001 -t 0010,1002 -t 0010,1005 -t 0010,1010 -t 0010,1020 \
  -t 0010,1021 -t 0010,1040 -t 0010,1050 -t 0010,1060 -t 0010,1080 \
  -t 0010,1081 -t 0010,1090 -t 0010,1100 -t 0010,2000 -t 0010,2110 \
  -t 0010,2150 -t 0010,2152 -t 0010,2154 -t 0010,2155 -t 0010,2160 \
  -t 0010,2180 -t 0010,21a0 -t 0010,21b0 -t 0010,21c0 -t 0010,21d0 \
  -t 0010,21f0 -t 0010,2203 -t 0010,2297 -t 0010,2298 -t 0010,2299 \
  -t 0010,4000 -t 0032,1030 -t 0032,1031 -t 0032,1032 -t 0038,0050 \
  -t 0038,0300 -t 0038,0500 -t 0038,0100 -t 0040,0006 -t 0040,000b \
  -t 4008,0114 -t 0040,3001 -t 0040,1400 | more

This will print the same summary of values, followed by a mapping for
each file. In this case you will want to see that no values are found
except for an empty string. If you want to be super sure, 

Values:

Mapping:
Filename: /path/to/some/file.dcm (could be read)
(0008,0050) -> []
(0008,0090) -> []
(0008,0092) -> []
(0008,0094) -> []
(0008,0096) -> []
(0008,009c) -> []
(0008,009d) -> []
(0008,1048) -> []
(0008,1049) -> []
(0008,1050) -> []
(0008,1052) -> []
(0008,1060) -> []
(0008,1062) -> []
(0008,1080) -> []
(0010,0010) -> []
(0010,0020) -> []
(0010,0021) -> []
(0010,0030) -> []
(0010,0032) -> []
(0010,0033) -> []
(0010,0034) -> []
(0010,0050) -> []
(0010,0101) -> []
(0010,1000) -> []
(0010,1001) -> []
(0010,1002) -> []
(0010,1005) -> []
(0010,1010) -> []
(0010,1020) -> []
(0010,1021) -> []
(0010,1030) -> []
(0010,1040) -> []
(0010,1050) -> []
(0010,1060) -> []
(0010,1080) -> []
(0010,1081) -> []
(0010,1090) -> []
(0010,1100) -> []
(0010,2000) -> []
(0010,2110) -> []
(0010,2150) -> []
(0010,2152) -> []
(0010,2154) -> []
(0010,2155) -> []
(0010,2160) -> []
(0010,2180) -> []
(0010,21a0) -> []
(0010,21b0) -> []
(0010,21c0) -> []
(0010,21d0) -> []
(0010,21f0) -> []
(0010,2203) -> []
(0010,2297) -> []
(0010,2298) -> []
(0010,2299) -> []
(0010,4000) -> []
(0032,1030) -> []
(0032,1031) -> []
(0032,1032) -> []
(0038,0050) -> []
(0038,0100) -> []
(0038,0300) -> []
(0038,0500) -> []
(0040,0006) -> []
(0040,000b) -> []
(0040,1400) -> []
(0040,3001) -> []
(4008,0114) -> []
