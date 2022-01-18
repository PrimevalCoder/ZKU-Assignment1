#!/bin/bash
echo "computing the witness..."
if node spawning_js/generate_witness.js spawning_js/spawning.wasm input.json witness.wtns 2>&1 >/dev/null | grep -q 'Error: Assert Failed'; then
  exit 1
fi
echo "generating proof..." &&
date &&
snarkjs groth16 prove spawning_0001.zkey witness.wtns proof.json public.json &&
echo "verifying proof..." &&
date &&
snarkjs groth16 verify verification_key.json public.json proof.json &&
echo "proof generated succesfully." &&
snarkjs generatecall > snark.txt