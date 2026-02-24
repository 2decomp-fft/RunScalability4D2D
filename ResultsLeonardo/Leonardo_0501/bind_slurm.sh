#!/bin/bash

export LOCAL_RANK=${SLURM_LOCALID}
export CUDA_VISIBLE_DEVICES=${LOCAL_RANK}

$* 

