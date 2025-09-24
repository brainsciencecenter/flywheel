#!/usr/bin/env python

import numpy as np

import pydicom
from pydicom.dataset import FileMetaDataset, FileDataset
from pydicom.uid import ExplicitVRLittleEndian, SecondaryCaptureImageStorage, generate_uid

import argparse
import datetime
import os
import sys

def make_noisy_dicom_copy(input_path, output_path, noise_std=1):
    # Load DICOM
    ds = pydicom.dcmread(input_path)

    # Add noise
    pixel_array = ds.pixel_array.astype(np.float32)
    noise = np.random.normal(0, noise_std, pixel_array.shape)
    noisy_array = pixel_array + noise

    # Clip to valid dtype range
    dtype = ds.pixel_array.dtype
    if dtype.kind == 'u':
        info = np.iinfo(dtype)
    else:
        info = np.iinfo(np.uint16)
    noisy_array = np.clip(noisy_array, info.min, info.max).astype(dtype)
    ds.PixelData = noisy_array.tobytes()

    # Update metadata
    now = datetime.datetime.now()
    ds.InstanceCreationDate = now.strftime('%Y%m%d')
    ds.InstanceCreationTime = now.strftime('%H%M%S')
    ds.StudyInstanceUID = generate_uid()
    ds.SeriesInstanceUID = generate_uid()
    ds.SOPInstanceUID = generate_uid()
    ds.AcquisitionDate = now.strftime('%Y%m%d')
    ds.AcquisitionTime = now.strftime('%H%M%S')
    ds.SeriesDate = now.strftime('%Y%m%d')
    ds.SeriesTime = now.strftime('%H%M%S')
    ds.SeriesDescription = 'TestDicom'
    ds.SeriesNumber = getattr(ds, 'SeriesNumber', 1) + 1000
    ds.InstanceNumber = getattr(ds, 'InstanceNumber', 1) + 1000

    # Ensure file_meta is set correctly
    file_meta = FileMetaDataset()
    file_meta.FileMetaInformationVersion = b'\x00\x01'
    file_meta.MediaStorageSOPClassUID = ds.SOPClassUID if 'SOPClassUID' in ds else SecondaryCaptureImageStorage
    file_meta.MediaStorageSOPInstanceUID = ds.SOPInstanceUID
    file_meta.TransferSyntaxUID = ExplicitVRLittleEndian
    file_meta.ImplementationClassUID = generate_uid()

    # Create a new FileDataset with meta
    new_ds = FileDataset(output_path, {}, file_meta=file_meta, preamble=b"\0" * 128)
    new_ds.update(ds)

    # Save as a new DICOM file
    ds.save_as(output_path, write_like_original=False)
    print(f"New DICOM saved to {output_path}")


def print_usage():
    print("Usage: python make_noisy_dicom.py <input.dcm> <output.dcm> [noise_std]")
    print("  input.dcm    Path to the input DICOM file")
    print("  output.dcm   Path where the noisy DICOM will be saved")
    print("  noise_std    (Optional) Standard deviation of Gaussian noise (default: 1.0)")
    sys.exit(1)

if __name__ == "__main__":

    ap = argparse.ArgumentParser()

    ap.add_argument('-N', '--noise', default=False, action='store', help="Noise factor, defaults to 1.0")
    ap.add_argument('-s', '--study-comments', required=True, default=False, action='store', help="StudyComments contents for flywheel processing")
    ap.add_argument('input_file', nargs=1, action='store', help='path to input dicom')
    ap.add_argument('output_file', nargs=1, action='store', help='path to output dicom')

    args = ap.parse_args()

    if len(sys.argv) < 3:
        print_usage()

    input_path = args.input_file[0]
    output_path = args.output_file[0]

    noise_std = float(args.noise) if (args.noise) else 1.0

    if not os.path.isfile(input_path):
        print(f"Error: Input file '{input_path}' does not exist.")
        sys.exit(1)

    try:
        make_noisy_dicom_copy(input_path, output_path, noise_std)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
