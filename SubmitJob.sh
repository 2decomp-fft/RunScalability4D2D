#!/bin/bash
if [ $# = 11 ]
then
 build=$1
 nn=$2
 nt=$3
 nr=$4
 nc=$5
 nx=$6
 ny=$7
 nz=$8
 tt=$9
 hh=${10}
 mm=${11}
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
   
jobname=Res${nxf}x${nyf}x${nzf}_NP${nnf}x${ntf}_2D${nrf}x${ncf}

cat > $jobname << TAG
#!/bin/bash
#
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

# Load the required modules

TestList="timing2d_real timing2d_complex fft_c2c_x fft_r2c_x fft_c2c_z fft_r2c_z"
for tt in \${TestList}
do
  cd ${build}/RunTests/\${tt}
  srun --distribution=block:block --hint=nomultithread ${build}/bin/\${tt} $nr $nc $nx $ny $nz $tt 2>&1 | grep -v "CRAYBLAS_WARNING" | grep -v "cray-libsci" | tee listing_\${tt}_${jobname}
done

TAG

chmod 755 $jobname
sbatch $jobname
