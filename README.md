# hpc_utils
This repository contains useful scripts and utilities for working with the HPC (High Performance Computing) environment.

## .bashrc
The `.bashrc` file contains useful aliases and functions for working with the HPC environment. It is recommended to source this file in your `.bashrc` or `.bash_profile` to make the aliases and functions available in your shell.

copy the `.bashrc_backup` file and replace the `.bashrc` file in your home directory with it and source it in your `.bashrc` or `.bash_profile`:

```bash
cp ~/.bashrc_backup ~/.bashrc
source ~/.bashrc
```
This file will be sourced automatically when you log in to the HPC environment next time, and it will set up your environment with the necessary aliases and functions.

### Key aliases
- `projects="/projects/$USER"`
- `scratch="/scratch/alpine/$USER"`

## Other scripts
- `merge_lanes_fastq.sh`: A script to merge FASTQ files from multiple lanes
- sharepoint transfer scripts: Scripts to transfer files between HPC and SharePoint. `transfer_to_sharepoint_fastq_v3.sh` and `sharepoint_to_local_transfer.sh` are the main scripts for transferring files to and from SharePoint. These scripts use `rclone` to transfer files and can be used to transfer large files efficiently.

