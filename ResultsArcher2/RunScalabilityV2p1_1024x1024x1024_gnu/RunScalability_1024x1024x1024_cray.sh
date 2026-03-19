#!/bin/bash
build=gnu11
nx=1024
ny=1024
nz=1024
NN=( 1 2 4 8 16 32 64)
NT=( 128 128 128 128 128 128 128)
hh=2
mm=00

for index in ${!NN[@]}; do
  n1="${NN[index]}"
  n2="${NT[index]}"
  np="$(($n1 * $n2 ))"
  echo $n1 $n2 $np
  sh ../SubmitJob.sh $build $n1 $n2 0 0 $nx $ny $nz $hh $mm 
  if [ $np -lt $nx ]; then 
    sh ../SubmitJob.sh $build $n1 $n2 1 $np $nx $ny $nz $hh $mm  
    sh ../SubmitJob.sh $build $n1 $n2 $np 1 $nx $ny $nz $hh $mm
  fi  
done

