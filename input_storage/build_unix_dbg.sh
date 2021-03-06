#!/usr/bin/bash
module load cmake
module load intel/parallel_studio_2019/ia32
#workaround just to include python2.7 and nothing else by linking it to a localbin/python
export PATH=~/localbin:$PATH
icc --version
ifort --version
FC=ifort
CC=icc
CXX=icpc
export FC
export CC
export CXX
cmake -E remove_directory BUILD_DBG
cmake -E make_directory BUILD_DBG
cd BUILD_DBG
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ../
#cmake --build . --target ALL_BUILD --config Debug
#cmake --build . --target ALL_BUILD --config Release
cmake --build .
