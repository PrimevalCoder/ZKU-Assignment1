# ZKU - Assignment 1
## Description
This is a minimal implementation of the basic ideas of the [Dark Forest](https://zkga.me) game. It uses zk proofs to keep the state of the game consistent.
Players choose a location, and, if the coordinates follow the constraints (there is a valid witness), a zk proof is generated for that location. This zk proof is sent to
the Ganache blockchain for validation. If everything checks out (proof is valid, location is unoccupied, and no one spawned there in the last 5 mins), the transaction
succeeds and the player is spawned.

## Requirements
This app uses [Web3.py](https://web3py.readthedocs.io/en/stable/), [Ganache](https://web3py.readthedocs.io/en/stable/), and [Circom](https://web3py.readthedocs.io/en/stable/).

## Usage
The app entrypoint is **interact.py**. First, you should choose *Set up ZK* in order to compile the circuit, create a trusted setup, and export the verifier contract.
Afterwards, deploy the verifier contract on Ganache using Remix and Metamask. Then, you can "play": choose an account, a location, and spawn. If the transaction is successful,
an event log is displayed. Make sure you choose a valid location. (Constraints: 32<sup>2</sup> < x<sup>2</sup> + y<sup>2</sup> <= 64<sup>2</sup>, gcd(x, y) > 1, and gcd(x, y) is not prime.)

