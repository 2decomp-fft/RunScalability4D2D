#!/bin/bash
path="/leonardo_work/EUHPC_B27_001/srolfo/2decomp-fft/build/"
builds=(
"nvhpc_nccl"
"nvhpc_nccl_even"
"nvhpc_nccl_single"
"nvhpc_nccl_even_single"
)
#builds=(
#"nvhpc_nccl"
#)
nx=501
ny=501
nz=501
tt=500
NN=( 1 1 1 2 4)
NT=( 1 2 4 4 4)
NCPUperNODE=8
hh=1
mm=30

for build in "${builds[@]}"; do
  for index in ${!NN[@]}; do
    n1="${NN[index]}"
    n2="${NT[index]}"
    np="$(($n1 * $n2 ))"
    ng=$n2
    echo $n1 $n2 $np $ng $NCPUperNODE
    sh ../SubmitJob_Leonardo.sh $path $build $n1 $n2 $np $n2 $ng 0 0 $nx $ny $nz $tt $hh $mm 
    if [ $np -le $nx ]; then
      echo "NP for slabs $np" 
      sh ../SubmitJob_Leonardo.sh $path $build $n1 $n2 $np $n2 $ng 1 $np $nx $ny $nz $tt $hh $mm  
      sh ../SubmitJob_Leonardo.sh $path $build $n1 $n2 $np $n2 $ng $np 1 $nx $ny $nz $tt $hh $mm
    fi  
  done
done

