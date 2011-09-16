#!/bin/env bash

# Benchmark wrapper for Antennae Band 7.

# Inputs
benchmarkScript='/users/jcrossle/casa/benchmark/benchmark.bash'
extractScript='/users/jcrossle/casa/benchmark/extractCASAscript.py'
calibrationGuideURL='http://casaguides.nrao.edu/index.php?title=Antennae_Band7_-_Calibration'
imagingGuideURL='http://casaguides.nrao.edu/index.php?title=Antennae_Band7_-_Imaging'
dataURL='https://almascience.nrao.edu/almadata/sciver/AntennaeBand7/Antennae_Band7_UnCalibratedMSandTablesForReduction.tgz'
dataLustre='/export/lustre/SV/AntennaeBand7/Antennae_Band7_UnCalibratedMSandTablesForReduction.tgz'
extractBenchmark='AntennaeBand7.extract.benchmark'

# Handle command line options
useURL=
while getopts 'b:u' OPTION
do
    case $OPTION in
    b)  scriptDir="$OPTARG"
        echo "Using scripts in $scriptDir"
        benchmarkScript=$scriptDir/benchmark.bash
        extractScript=$scriptDir/extractCASAscript.py
        ;;
    u)  useURL=1 # Get data by HTTP; else filesystem
        ;;
    ?)  printf "Usage: %s [-b scriptDir] [-u]\n" $(basename $0) >&2
        echo "  scriptDir = directory containing benchmarking scripts" >&2
        echo "  -u = get data by HTTP rather than filesystem" >&2
        exit 2
        ;;
    esac
done
shift $(($OPTIND -1))

# Import functions
. $benchmarkScript

# Extract data
if [ "$useURL" ]
then
    extractionTest $dataURL $extractBenchmark
else
    extractionTest $dataLustre $extractBenchmark
fi
cd $dir

# Run casa guides tests
for URL in $calibrationGuideURL $imagingGuideURL
do
    casaGuidesTest $extractScript $URL
done

cd ..
echo "Benchmark wrapper finished."
