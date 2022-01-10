Instructions for running TensorFlow on Cirrus (GPU)
===================================================

These instructions are for running TensorFlow on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

TensorFlow 2.7.0 is made available by loading the `tensorflow/2.7.0-gpu` module; this starts a Miniconda3 environment
containing Horovod 0.23.0 and mpi4py 3.1.3 (built against Open MPI 4.1.0 and CUDA 11.2).

Horovod is a key component as it allows the TensorFlow work to be distributed over CPUs and/or GPUs,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

The submission script below shows how to run TensorFlow over multiple GPU nodes.
The job runs a CNN benchmark script located within `/lustre/home/shared/ml/tensorflow/benchmarks` and
executes over 4 Cascade Lake GPU nodes using 4 GPUs per node (hence, there are 4 MPI ranks per node).


Launch a TensorFlow synthetic image-recognition benchmark
---------------------------------------------------------

The script below launches a TensorFlow job that uses 16 GPUs across 4 Cascade Lake GPU nodes.


```bash
#!/bin/bash

#SBATCH --job-name=hvtf
#SBATCH --time=00:20:00
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

export SLURM_NTASKS=16
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module use /lustre/sw/modulefiles.miniconda3
module load tensorflow/2.7.0-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

BENCHMARKS_PATH=/lustre/home/shared/ml/tensorflow/benchmarks/scripts/tf_cnn_benchmarks

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARKS_PATH}/tf_cnn_benchmarks.py \
        --data_format=NCHW --model=resnet50 --variable_update=horovod --num_gpus=1
```


If you wish to increase the number of GPUs to 32 for example, you will need to make
two changes to the script above.

```bash
...
#SBATCH --nodes=8
...
export SLURM_NTASKS=32
...
```

And if you wish to adjust the number of GPUs per node you will need to change
the `#SBATCH --gres=gpu:4` directive also.


Please note, the above example uses a synthetic benchmark, i.e., one that uses a set of images
that the ResNet-50 CNN is known to identify successfully. 


Launch a TensorFlow non-synthetic image-recognition benchmark
-------------------------------------------------------------

```bash
#!/bin/bash

#SBATCH --job-name=hvtf
#SBATCH --time=00:20:00
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH --partition=gpu-cascade
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=[budget code]

export SLURM_NTASKS=16
export SLURM_NTASKS_PER_NODE=`expr ${SLURM_NTASKS} \/ ${SLURM_NNODES}`
export SLURM_TASKS_PER_NODE="${SLURM_NTASKS_PER_NODE}(x${SLURM_NNODES})"

module use /lustre/sw/modulefiles.miniconda3
module load tensorflow/2.7.0-gpu

scontrol show hostnames > ${SLURM_SUBMIT_DIR}/hosts

SHARED_ML_ROOT=/lustre/home/shared/ml
BENCHMARKS_PATH=${SHARED_ML_ROOT}/tensorflow/benchmarks/scripts/tf_cnn_benchmarks
DATA_DIR=${SHARED_ML_ROOT}/datasets/imagenet-tf-rec

mpirun -n ${SLURM_NTASKS} -N ${SLURM_NTASKS_PER_NODE} \
    -hostfile ${SLURM_SUBMIT_DIR}/hosts -bind-to none -map-by slot \
    -x HOROVOD_MPI=1 -x HOROVOD_MPI_THREADS_DISABLE=1 \
    -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH -x PATH \
    python ${BENCHMARKS_PATH}/tf_cnn_benchmarks.py \
        --data_format=NCHW --model=resnet50 --variable_update=horovod --num_gpus=1 \
        --data_dir=${DATA_DIR} --print_training_accuracy=True
```