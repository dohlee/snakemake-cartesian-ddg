#!/bin/bash

$ROSETTABIN/relax.static.linuxgccrelease -s $1 -use_input_sc \
-ignore_unrecognized_res \
-nstruct 20 \
-relax:cartesian \
-out:path:pdb $2 \
-out:path:score $3 \
-out:file:scorefile $4 \
-score:weights ref2015_cart \
-relax:min_type lbfgs_armijo_nonmonotone \
-relax:script cart2.script \
-fa_max_dis 9.0
