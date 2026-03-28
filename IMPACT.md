## All IMPACT students have access to CHIMERA24 (aka the NEW DGX H200!)

Login to the cluster headnode via ssh:  

`ssh first.last001@chimera.umb.edu`

DO NOT RUN JOBS HERE - just connect to the new DGX H200 MACHINE CHIMERA24 like this:

`salloc -c2 -A impact -q aicore --gres=gpu:1 --mem=32G -w chimera24 -p AICORE_H200 -t 60`

This will grab 2 CPU Cores with 32GB RAM and 1 GPU for 60 minutes.

### Create Conda Environment

1. Download and install Miniconda.

`curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh`

`chmod +x Mini*`

`./Mini*`

2. Now we can create the IMPACT environment with Tensorflow and Jupyter.

`conda create -n IMPACT python=3.10`

`conda activate IMPACT`

`pip install "tensorflow[and-cuda]"`

`pip install jupyterlab ipykernel`

We need to set up some library paths. The code will do this automatically if we set it up once.

`mkdir -p $CONDA_PREFIX/etc/conda/activate.d`

`nano $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh`

And then in the editor, paste the following:

```
export LD_LIBRARY_PATH=$(python - <<'PY'
import site, os, glob
paths=[]
for p in site.getsitepackages():
    paths += glob.glob(os.path.join(p,"nvidia","*","lib"))
print(":".join(paths))
PY
):$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
```

Save and exit.

### Reload the environment.

`conda deactivate`

`conda activate IMPACT`

### GPU Test.

`python -c "import tensorflow as tf; print(tf.config.list_logical_devices('GPU'))"`

This should list the GPU!
