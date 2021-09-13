# INDDID,FlywheelSubjectID,FlywheelSessionTimestampUTC,FlywheelSessionURL,FlywheelSessionInternalID,FlywheelProjectInternalID,FlywheelAcquisitionLabel,FlywheelAcquisitionIntent,FlywheelAcquisitionMeasurement,FlywheelAcquisitionFeatures,FlywheelAcquisitionInternalID,AcquisitionTimestampUTC,DicomModality,DicomInstitutionName,DicomStationName,DicomBodyPartExamined,DicomStudyInstanceUID,DicomSeriesInstanceUID,DicomSliceThickness,DicomPixelSpacingX,DicomPixelSpacingY,DicomMagneticFieldStrength,DicomSequenceName,DicomRepetitionTime,DicomEchoTime,DicomEchoNumbers,DicomFlipAngle,DicomNumberOfAverages,DicomAcquisitionNumber,DicomSpacingBetweenSlices


import "Id2ProjectLabels" as $ProjectId2Labels;
import "Id2SubjectLabels" as $SubjectId2Labels;
import "Id2SessionLabels" as $SessionId2Labels;

      .parents.group as $GroupLabel 
    | .parents.project as $ProjectId
    | .parents.subject as $SubjectId
    | .parents.session as $SessionId

    | $ProjectId2Labels::ProjectId2Labels[][.parents.project] as $ProjectLabel 
    | $SubjectId2Labels::SubjectId2Labels[][.parents.subject] as $SubjectLabel 
    | $SessionId2Labels::SessionId2Labels[][.parents.session] as $SessionLabel 
    | ._id as $AcquisitionId
    | .label as $AcquisitionLabel 
    | (if (.timestamp) then .timestamp else .created end) as $TimeStamp
    | .files[]
      | select((.type) and (.type | match("dicom")) and (.name | match(".zip$")))
      | .info

        # Need to check file names for ^IND{1,2}_.*$, ^\d{6}$, ^\d{6}[._\-x]\d{2}$

        | [ 
            $SubjectLabel,
            $SubjectId,
            $TimeStamp,  # should be the session timestamp
            "https://upenn.flywheel.io/#/projects/\($ProjectId)/sessions/\($SessionId)/?tab=data",
            $SessionId,
            $ProjectId,
            $AcquisitionLabel,
            (if .classification.Intent then .classification.Intent|join(";") else "" end),
            (if .classification.Measurement then .classification.Measurement|join(";") else "" end),
            (if .classification.Features then .classification.Features|join(";") else "" end),
            $AcquisitionId,
            $TimeStamp,
            .Modality,
            .InstitutionName,
            .StationName,
            .BodyPartExamined,
            .StudyInstanceUID,
            .SeriesInstanceUID,
            .SliceThickness,
            .PixelSpacing[0],
            .PixelSpacing[1],
            .MagneticFieldStrength,
            .SequenceName,
            .RepetitionTime,
            .EchoTime,
            .EchoNumbers,
            .FlipAngle,
            .NumberOfAverages,
            .AcquisitionNumber,
            .SpacingBetweenSlices
          ] | @csv
