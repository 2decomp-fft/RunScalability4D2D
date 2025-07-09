#!/bin/bash
build=$D2D_build_path
nx=1024
ny=1024
nz=1024
tt=100
NN=( 1 2 4 8 16 32 64)
NT=( 128 128 128 128 128 128 128)
#NN=( 8 )
#NT=( 128 )
hh=2
mm=00

for index in ${!NN[@]}; do
  n1="${NN[index]}"
  n2="${NT[index]}"
  np="$(($n1 * $n2 ))"
  echo $n1 $n2 $np
  sh ../SubmitJob.sh $build $n1 $n2 0 0 $nx $ny $nz $tt $hh $mm 
  if [ $np -le $nx ]; then 
    sh ../SubmitJob.sh $build $n1 $n2 1 $np $nx $ny $nz $tt $hh $mm  
    sh ../SubmitJob.sh $build $n1 $n2 $np 1 $nx $ny $nz $tt $hh $mm
  fi  
done

