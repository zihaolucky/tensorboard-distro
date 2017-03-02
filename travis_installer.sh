#!/usr/bin/env bash

# fetch tensorboard
git clone https://github.com/dmlc/tensorboard.git tensorboard-build
# replace setup.py
cp setup.py tensorboard-build/python/
# replace tools for travis build
cp -r tools/* tensorboard-build/tools/
cd tensorboard-build

# make protobufs for logging part first
make all

# get tensorflow
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
# chekcout a specific tag, currently we use v1.0.0-rc1
git checkout -b v1.0.0-rc1 v1.0.0-rc1

# run configuration.
bash configure < ../../tools/travis_wheel/configure.conf
# hack bazel compile time
git apply ../../tools/travis_wheel/bazel-hacking.patch
# build tensorboard
bazel build tensorflow/tensorboard:tensorboard

# get .whl file in python/dist/
bash bazel-bin/tensorflow/tools/pip_package/build_pip_package.sh ../python/dist/

# install tensorboard package from .whl file
set -eo pipefail

cd ..
rm python/README*
cp -r python/* ../
pip install python/dist/*.whl

# clean up
rm -rf tensorflow/

# back to top
cd ..

# @szha: this is a workaround for travis-ci#6522
set +e
