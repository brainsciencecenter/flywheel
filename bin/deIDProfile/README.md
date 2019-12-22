# fwCustomDeidentification

Script to generate a custom profile for de-identification of data by the Flywheel CLI.
The profiles here are designed for uploading data to the UPenn Flywheel only. The data
should be kept confidential and accessible only by approved personnel. 

The profiles here are **NOT** suitable for any kind of public data sharing.

## Example usage 

If dicom data for a single scan is in `/path/to/dicomDir`, then it can
be de-identified during import with:

```
fw import dicom /path/to/dicomDir pennftdcenter aProject \
  --subject subjectID \
  --session sessionID \
  --output-folder /path/to/testOutput \
  --profile globalDeIdConfig.yaml
```

This does a dry run, outputing data to a local file system. Without
the `--output-folder` option, the data will be imported to
Flywheel. See the [Flywheel documentation](https://docs.flywheel.io/hc/en-us/articles/360008548134-CLI-Command-import-dicom-)
for more information.


## Included profiles

Most users should use the official profile at
`profiles/PennBrainScienceCenter/de-id_upenn_Penn_BSC_profile_v1.0_20190906A.yaml`. This
is the same profile used for data reaped from HUP6. See the README
there for some examples on how to test the output for successful
de-identification.


## Custom de-identification profiles

For more background and examples of other capabilities, see [Custom
de-Identification of dicom field through the CLI](https://docs.flywheel.io/hc/en-us/articles/360008972493-Custom-de-Identification-of-dicom-field-through-the-CLI). 


## Generating a profile

First define CSV files containing tags to remove or replace, following the format shown in
the `profiles/` directory. A dictionary of keywords is included under the `dicom/`
directory. There's also an example there showing how to access the dictionary in
`pydicom`. 

When you have the tags you want to process, run
`config/generateDeidConfig.pl`.

Always test the profile first before sending data to Flywheel.


## Further reading on de-identification

[DICOM standard de-identification
profiles](http://dicom.nema.org/medical/dicom/current/output/html/part15.html#chapter_E). Description of official de-identification profiles.

[Free DICOM de-identification tools in clinical research: functioning and safety of
patient privacy](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4636522/). Testing some
popular DICOM tools, and showing the difficulty in successfully de-identifying DICOM data.

[De-identification of Medical Images with Retention of Scientific Research
Value](https://pubs.rsna.org/doi/full/10.1148/rg.2015140244). From the Cancer Imaging
Archive team. "It is extremely difficult to eradicate all PHI from DICOM images with
automated software while at the same time retaining all useful information." A more
detailed discussion of their de-identification routines can be found on the [Cancer Imaging
Archive Wiki](https://wiki.cancerimagingarchive.net/display/Public/Submission+and+De-identification+Overview). 


