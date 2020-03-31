# Complete Installation for Jetson Nano!
#
# based on https://www.pyimagesearch.com/2020/03/25/how-to-configure-your-nvidia-jetson-nano-for-computer-vision-and-deep-learning/


sudo nvpmodel -m 0
sudo jetson_clocks

sudo apt-get purge libreoffice*
sudo apt-get clean


sudo apt-get update && sudo apt-get upgrade



sudo apt-get install -y git cmake libatlas-base-dev gfortran libhdf5-serial-dev hdf5-tools python3-dev vim locate libfreetype6-dev python3-setuptools protobuf-compiler libprotobuf-dev openssl libssl-dev libcurl4-openssl-dev cython3 libxml2-dev libxslt1-dev

#
# CMake
#
mkdir Scratch
cd Scratch
wget http://www.cmake.org/files/v3.13/cmake-3.13.0.tar.gz
tar xpvf cmake-3.13.0.tar.gz cmake-3.13.0/
cd cmake-3.13.0/
./bootstrap --system-curl
make -j8

echo 'export PATH=~/Scratch/cmake-3.13.0/bin/:$PATH' >> ~/.bashrc
source ~/.bashrc

# 
# OpenCV Libraries
#
sudo apt-get install -y build-essential pkg-config libtbb2 libtbb-dev libavcodec-dev libavformat-dev libswscale-dev libxvidcore-dev libavresample-dev libtiff-dev libjpeg-dev libpng-dev python-tk libgtk-3-dev libcanberra-gtk-module libcanberra-gtk3-module libv4l-dev libdc1394-22-dev

#
# VirtualEnv
#
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
rm get-pip.py

sudo pip install virtualenv virtualenvwrapper

vim ~/.bashrc

# virtualenv and virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh


source ~/.bashrc 


mkvirtualenv COMPLETE -p python3
workon COMPLETE

#
# ProtoBuf
#
wget https://raw.githubusercontent.com/jkjung-avt/jetson_nano/master/install_protobuf-3.6.1.sh
sudo chmod +x install_protobuf-3.6.1.sh
./install_protobuf-3.6.1.sh


cp -r ~/src/protobuf-3.6.1/python Scratch/
cd ~/Scratch/python
python setup.py install --cpp_implementation

#
# Numpy and Cython
#
pip install numpy cython

#
# Scipy
#
cd ~/Scratch
wget https://github.com/scipy/scipy/releases/download/v1.3.3/scipy-1.3.3.tar.gz
tar -xzvf scipy-1.3.3.tar.gz scipy-1.3.3
cd scipy-1.3.3/
python setup.py install

#
# TF and Keras
#
pip install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu==1.13.1+nv19.3
pip install keras


#
# TFOD API
#
git clone https://github.com/tensorflow/models
cd models && git checkout -q b00783d
cd ~/Scratch/
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
python setup.py install
cd ~/Scratch/models/research/
protoc object_detection/protos/*.proto --python_out=.

#
# Re-usable script
#
vim ~/setup.sh

# add this content:
#

#!/bin/sh
export PYTHONPATH=$PYTHONPATH:/home/`whoami`/Scratch/models/research:\
/home/`whoami`/Scratch/models/research/slim

#
# tf_trt_models
#
cd ~/Scratch/
git clone --recursive https://github.com/NVIDIA-Jetson/tf_trt_models.git
cd tf_trt_models
./install.sh

#
# OpenCV
#
cd ~/Scratch/
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.1.2.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.1.2.zip
unzip opencv.zip
unzip opencv_contrib.zip
mv opencv-4.1.2 opencv
mv opencv_contrib-4.1.2 opencv_contrib

cd opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D WITH_CUDA=ON \
  -D CUDA_ARCH_PTX="" \
  -D CUDA_ARCH_BIN="5.3,6.2,7.2" \
  -D WITH_CUBLAS=ON \
  -D WITH_LIBV4L=ON \
  -D BUILD_opencv_python3=ON \
  -D BUILD_opencv_python2=OFF \
  -D BUILD_opencv_java=OFF \
  -D WITH_GSTREAMER=ON \
  -D WITH_GTK=ON \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_EXAMPLES=OFF \
  -D OPENCV_ENABLE_NONFREE=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/home/`whoami`/Scratch/opencv_contrib/modules ..


make -j 4
sudo make install

cd ~/.virtualenvs/COMPLETE/lib/python3.6/site-packages/
ln -s /home/`whoami`/Scratch/opencv/build/lib/python3/cv2.cpython-36m-aarch64-linux-gnu.so cv2.so

#
# other packages
#
pip install matplotlib scikit-learn pillow imutils scikit-image flask dlib jupyter lxml progressbar2


