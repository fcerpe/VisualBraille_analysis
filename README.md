## Gun-Zipping all nifti files in a folder and subfolders

```bash
find path_to_folder -type f -name '*.nii' -exec gzip "{}" \;
```

## Tips to run typical containers

Most headaches with docker commands come from making sure you pass the correct
path to the container. Having the same folder structure should help you avoiding
mistakes and allow to reuse the same commands.

Some examples below. Of course you may need to adapt the actual docker command
to your needs.

```
├── code
│   ├── README.md
│   ├── deface.sh
│   ├── run_fmriprep.sh
│   └── run_mriqc.sh
├── inputs
│   └── raw
│       ├──README
│       ├──dataset_description.json
│       ├── sub-01
│       ├── sub-02
│       ├── sub-03
│       ├── sub-04
│       ├── sub-05
│       └── sub-06
├── outputs
│   └── derivatives
└── sourcedata
```

Go into the code folder.

```bash
cd code
```

And then run the bash commands below.

## Defacing all images

Run the following to deface all participants at once.

```bash
bids_dir=$(pwd)/../inputs/raw

docker run -i --rm \
    -v $bids_dir:/bids_dataset \
    peerherholz/bidsonym /bids_dataset group \
    --deid quickshear \
    --brainextraction bet \
    --bet_frac 0.5
```

## MRIQC

Run the following to deface all participants at once: all tasks and imaging
modalities.

```bash
bids_dir=$(pwd)/../inputs/raw
derivatives_dir=$(pwd)/../outputs/derivatives

docker run -it --rm \
    -v $bids_dir:/data:ro \
    -v $derivatives_dir:/out \
    poldracklab/mriqc:0.16.1 /data /out \
    participant \
    --verbose-reports
```

## fMRIprep

For fmriprep

```bash
#update this to your participant label
participants="001 002"

code_dir=$(pwd)
bids_dir=$(pwd)/../inputs/raw
derivatives_dir=$(pwd)/../outputs/derivatives

docker run -it --rm \
    -v $code_dir:/code:ro \
    -v $bids_dir:/data:ro \
    -v $derivatives_dir:/out \
    nipreps/fmriprep:20.2.6 /data /out \
    participant --participant_label ${participants} \
    --fs-license-file /code/license.txt \
    --output-spaces T1w:res-native MNI152NLin2009cAsym:res-native
```
