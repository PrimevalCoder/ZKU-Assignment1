#!/bin/bash
echo "compiling circuit..." &&
date &&
circom spawning.circom --r1cs --wasm --sym --c &&
echo "creating the trusted setup..." &&
echo "phase 1, which is circuit-independent..." &&
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v &&
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v &&
echo "phase 2, which is circuit-specific..." &&
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v &&
snarkjs groth16 setup spawning.r1cs pot12_final.ptau spawning_0000.zkey &&
snarkjs zkey contribute spawning_0000.zkey spawning_0001.zkey --name="Horus" -v &&
snarkjs zkey export verificationkey spawning_0001.zkey verification_key.json &&
echo "exporting verifier contract..." &&
date &&
snarkjs zkey export solidityverifier spawning_0001.zkey verifier.sol &&
echo "done!" &&
date
