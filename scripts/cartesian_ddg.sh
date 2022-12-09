#!/bin/bash

# $1 = pdb
# $2 = mutfile

$ROSETTABIN/cartesian_ddg.static.linuxgccrelease \
-database $ROSETTADB \
-s $1 \
-ddg:mut_file $2 \
-ddg:iterations 3 \
-force_iterations false \
-ddg::score_cutoff 1.0 \
-ddg::cartesian \
-ddg::dump_pdbs false \
-ddg:bbnbrs 1 \
-fa_max_dis 9.0 \
-score:weights ref2015_cart \
-ddg::legacy false
