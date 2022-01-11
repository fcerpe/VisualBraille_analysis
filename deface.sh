#!/bin/bash

bids_dir=$(pwd)/../inputs/raw

docker run -i --rm \
    -v $bids_dir:/bids_dataset \
    peerherholz/bidsonym /bids_dataset group \
    --deid quickshear \
    --brainextraction bet \
    --bet_frac 0.5
