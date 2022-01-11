#!/bin/bash
# Suggestion: copy-paste this into linux and run it


cd ../../mnt/c/Users/filip/Documents/Gin/VisualBraille/analysis/code

bids_dir=$(pwd)/../inputs/raw
derivatives_dir=$(pwd)/../outputs/derivatives

docker run -it --rm \
    -v $bids_dir:/data:ro \
    -v $derivatives_dir:/out \
    poldracklab/mriqc:0.16.1 /data /out \
    participant \
    --verbose-reports
