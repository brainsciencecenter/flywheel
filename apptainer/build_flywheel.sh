#!/bin/bash
#SBATCH --job-name=build_flywheel
#SBATCH --output=build_flywheel-%j.out
#SBATCH --partition=short
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=0:30:00

apptainer build ${TMPDIR}/flywheel.sif flywheel.def

[[ -f ${TMPDIR}/flywheel.sif ]] && mv ${TMPDIR}/flywheel.sif .
