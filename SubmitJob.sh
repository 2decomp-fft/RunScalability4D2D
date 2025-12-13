#!/bin/bash
if [ $# = 11 ]
then
 path=$1
 build=$2
 nn=$3
 nt=$4
 nr=$5
 nc=$6
 nx=$7
 ny=$8
 nz=$9
 tt=$10
 hh=${11}
 mm=${12}
else
 echo "Run Test Suite for 2decomp"
 echo "Inputs: build_name nn nt nr nc nx ny nx n_iterations hour min"
fi

nxf=$(printf "%04d" $nx)
nyf=$(printf "%04d" $ny)
nzf=$(printf "%04d" $nz)
nnf=$(printf "%04d" $nn)
ntf=$(printf "%04d" $nt)
nrf=$(printf "%04d" $nr)
ncf=$(printf "%04d" $nc)
   
DATE=$(date +'%Y-%m-%d_%H-%M')
echo "DATE $DATE"
echo "BUILD $build"
echo "PATH $path"
jobname=Res${build}${nxf}x${nyf}x${nzf}_NP${nnf}x${ntf}_2D${nrf}x${ncf}
filename=${jobname}.slurm
echo $jobname
work_dir=${DATE}_${jobname}

cat > $filename << TAG
#!/bin/bash
#
#SBATCH --job-name=${jobname}              
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --time=${hh}:${mm}:00
#SBATCH --exclusive
#SBATCH --nodes=${nn}
#SBATCH --tasks-per-node=$nt
#SBATCH --output=%x.%j.out

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=z19-upgrade2025
#SBATCH --reservation=z19-upgrade2025
#SBATCH --qos=reservation

mkdir ${work_dir}
cd ${work_dir}

# Load the required modules

TestList="timing2d_real timing2d_complex fft_c2c_x fft_r2c_x fft_c2c_z fft_r2c_z"
for tt in \${TestList}
do
  srun --distribution=block:block --hint=nomultithread ${path}${build}/bin/\${tt} $nr $nc $nx $ny $nz $tt 2>&1 | grep -v "CRAYBLAS_WARNING" | grep -v "cray-libsci" | tee listing_\${tt}
done

TAG

chmod 755 $filename
sbatch $filename
