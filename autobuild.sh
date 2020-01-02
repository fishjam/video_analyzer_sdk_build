#!/bin/bash

#function fun_log (){
#  echo "`date +'%Y-%m-%d %k:%M:%S'` $*"
#}
#
##usage: fun_check_error "$? -eq 0" "build source code"
#function fun_check_error(){
#    # echo "check " $1
#    if [[ ! $1 ]]; then
#        fun_log "$2 error.."
#        exit -1
#    fi
#}

ROOT_DIR=$(cd `dirname $0`;pwd)
OS_TYPE=`uname`

if [[ "${OS_TYPE}" == "Linux" ]] ; then
  BIN_PATH=bin/linux-x64/videoAnalyzer
elif [[ "${OS_TYPE}" == "Darwin" ]] ; then
  BIN_PATH=bin/macos-x64/videoAnalyzer
fi

#mkdir -p leptonica/build
#cd leptonica/build
#cmake -DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/result/${OS_TYPE} ..
#make && make install

# -DLeptonica_Dir=${ROOT_DIR}/result/${OS_TYPE}/cmake

#cd tesseract/build
#cmake -DBUILD_TRAINING_TOOLS=OFF -DCMAKE_VERBOSE_MAKEFILE=TRUE \
#   -DLeptonica_DIR=${ROOT_DIR}/result/${OS_TYPE}/Linux/cmake \
#   -DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/result/${OS_TYPE} ..

cd opencv/build
cmake -DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/result/${OS_TYPE} \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_opencv_world=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_EXAMPLES=OFF \
        ..


cd ${ROOT_DIR}