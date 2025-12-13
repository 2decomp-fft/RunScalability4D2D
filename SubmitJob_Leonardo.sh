#!/bin/bash
if [ $# = 15 ]
then
 path=$1
 build=$2
 nn=$3
 nt=$4
 np=$5
 ncpupernode=$6
 ngpupernode=$7
 nr=$8
 nc=$9
 nx=${10}
 ny=${11}
 nz=${12}
 tt=${13}
 hh=${14}
 mm=${15}
else
 echo "Run Test Suite for 2decomp"
 echo "Inputs: build_name nn nt nt_tot cpus-per-task gpus-per-node nr nc nx ny nx n_iterations hour min"
fi
nxf=$(printf "%04d" $nx)
nyf=$(printf "%04d" $ny)
nzf=$(printf "%04d" $nz)
nnf=$(printf "%04d" $nn)
ntf=$(printf "%04d" $nt)
nrf=$(printf "%04d" $nr)
ncf=$(printf "%04d" $nc)
qos=normal
   
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
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=${qos}
#SBATCH --time=${hh}:${mm}:00
#SBATCH --exclusive
#SBATCH --nodes=${nn}
#SBATCH --ntasks-per-node=${nt}               # Number of MPI tasks per node (e.g., 1 per GPU)
#SBATCH --cpus-per-task=${ncpupernode}        # Number of CPU cores per task (adjust as needed)
#SBATCH --gres=gpu:${ngpupernode}             # Number of GPUs per node (adjust to match hardware)
#SBATCH --output=%x.%j.out

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=EUHPC_B27_001

module purge
ml nvhpc/25.3
ml hpcx-mpi

export OMP_NUM_THREADS=1        # Set OpenMP threads per task
#export NCCL_DEBUG=INFO         # Enable NCCL debugging (for multi-GPU communication)

mkdir ${work_dir}
cp bind_slurm.sh ${work_dir}
cd ${work_dir}

# Load the required modules

TestList="timing2d_real timing2d_complex fft_c2c_x fft_r2c_x fft_c2c_z fft_r2c_z"
for tt in \${TestList}
do
  srun --distribution=block:block --hint=nomultithread --kill-on-bad-exit=1 ./bind_slurm.sh ${path}$build/bin/\${tt} $nr $nc $nx $ny $nz $tt 2>&1 | tee listing_\${tt}
done

TAG

chmod 755 $filename
sbatch $filename
