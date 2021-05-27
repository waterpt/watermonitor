#!/bin/bash
#
git clone https://github.com/cobilab/falcon.git
cd falcon/src/
cmake .
make
cp FALCON ../../
cp FALCON-filter ../../
cp FALCON-filter-visual ../../
cp FALCON-inter  ../../
cp FALCON-inter-visual ../../
cd ../../
#
