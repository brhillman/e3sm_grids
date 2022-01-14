#!/bin/bash

source config.sh
mkdir -p ${output_root}
GenerateCSMesh --alt --res 4 --file ${output_root}/ne4.g
