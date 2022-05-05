#!/usr/bin/env python3
from subprocess import call
from grid_config import se_ne, output_root
import os

os.makedirs(output_root, exist_ok=True)
call(f'GenerateCSMesh --alt --res {se_ne} --file {output_root}/ne{se_ne}.g'.split(' '))
