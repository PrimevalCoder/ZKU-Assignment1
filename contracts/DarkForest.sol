// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) external view returns (bool);
}

contract DarkForest {

    address public verifierAddr;

    // construct the contract with a ZK proof verifier
    constructor(address _verifier) {
       verifierAddr = _verifier;
    }

    struct positionStatus {
        bool occupied;
        uint lastSpawn;
    }
    mapping(address => uint) private playerPosition;    // player position is a hash value
    mapping(uint => positionStatus) positionState;      // we trace the status of positions in the game world

    event Spawn(address player, uint position);         // send Spawn events when players successfully spawn

    // A valid position for spawning should be 1) unoccupied, and 2) no player spawned there in the last 5 mins
    function checkHistory(uint _position) private view returns (bool) {
        bool st_elapsed = (block.timestamp - positionState[_position].lastSpawn) > 5 minutes;
        bool free_spot = !(positionState[_position].occupied);
        return (st_elapsed && free_spot);
    }

    function verifyPlayerProof (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) private view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    /** 
     * @dev spawn players
     */
    function spawn(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input    
    ) public {
        // input[0] = h
        require(checkHistory(input[0]), "Other players have spawned at this position within the last 5 minutes, or the position is occupied.");
        require(verifyPlayerProof(a, b, c, input), "Proof is invalid.");

        // free the previous position & occupy the new one
        if(playerPosition[msg.sender] != 0)
            positionState[ playerPosition[msg.sender] ].occupied = false;
        playerPosition[msg.sender] = input[0];
        positionState[input[0]].occupied = true;
        positionState[input[0]].lastSpawn = block.timestamp;
        emit Spawn(msg.sender, input[0]);
    }

}