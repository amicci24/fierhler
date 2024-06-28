// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBlockchain {             
    struct Transaction {                // Struct to define a transaction
        address sender;                 // Address of the sender
        address receiver;               // Address of the receiver
        uint256 value;                  // Value (amount) of the transaction
    }

    struct Block {
        uint256 number;                 // Block number
        uint256 timestamp;              // Block timestamp
        mapping(uint256 => Transaction) transactions;   // Mapping of transaction index to Transaction struct
        uint256 transactionCount;       // Number of transactions in the block
        bytes32 parentHash;             // Hash of the parent block
        address investor;               // Address of the investor
        string investmentType;          // Type of investment
        uint256 investmentAmount;       // Amount invested
        uint256 nonce;                  // Nonce used for proof of work
        bytes32 hash;                   // Hash of the bloc
    }

    Block[] public blockchain;          // Array to store blocks
    Transaction[] public pendingTransactions;   // Array to store pending transactions
    uint256 public difficulty = 3;      // Mining difficulty
    uint256 public blockSize = 3;       // Maximum size of each block
    address public miner = 0x0000000000000000000000000000000000000000; // Placeholder miner address

    constructor(address investor, string memory investmentType, uint256 investmentAmount) {
        // Genesis block
        mineBlock(investor, investmentType, investmentAmount, true);
    }

    function addTransaction(address receiver, uint256 value) public {
        pendingTransactions.push(Transaction(msg.sender, receiver, value));
    }                                   // Function to mine a new block

    function mineBlock(address investor, string memory investmentType, uint256 investmentAmount, bool genesis) public {
        uint256 blockNumber = genesis ? 1 : blockchain[blockchain.length - 1].number + 1;
        bytes32 parentHash = genesis ? bytes32(0) : blockchain[blockchain.length - 1].hash;

        // Create a new block
        Block storage newBlock = blockchain.push();
        newBlock.number = blockNumber;
        newBlock.timestamp = block.timestamp;
        newBlock.parentHash = parentHash;
        newBlock.investor = investor;
        newBlock.investmentType = investmentType;
        newBlock.investmentAmount = investmentAmount;

        // Add transactions to the block
        uint256 transactionCount = pendingTransactions.length > blockSize ? blockSize : pendingTransactions.length;
        newBlock.transactionCount = transactionCount;
        for (uint256 i = 0; i < transactionCount; i++) {
            newBlock.transactions[i] = pendingTransactions[i];
        }

        // Calculate the proof of work and set the block hash
        newBlock.hash = calculateProofOfWork(newBlock);

        // Adjust the pendingTransactions array
        Transaction[] memory newPendingTransactions = new Transaction[](pendingTransactions.length > blockSize ? pendingTransactions.length - blockSize : 0);
        for (uint256 i = 0; i < newPendingTransactions.length; i++) {
            newPendingTransactions[i] = pendingTransactions[i + blockSize];
        }
        delete pendingTransactions; // Clear the old array
        for (uint256 i = 0; i < newPendingTransactions.length; i++) {
            pendingTransactions.push(newPendingTransactions[i]);
        }

        // Reward miner with a new transaction
        pendingTransactions.push(Transaction(address(0), miner, 0));
    }

    function calculateHash(Block storage blockData, uint256 nonce) private view returns (bytes32) {
        bytes32 hash;
        for (uint256 i = 0; i < blockData.transactionCount; i++) {
            hash = keccak256(
                abi.encodePacked(
                    blockData.number,
                    blockData.timestamp,
                    blockData.transactions[i].sender,
                    blockData.transactions[i].receiver,
                    blockData.transactions[i].value,
                    blockData.parentHash,
                    blockData.investor,
                    blockData.investmentType,
                    blockData.investmentAmount,
                    nonce
                )
            );
        }
        return hash;
    }                                   // Calculate the hash of a block with a given nonce

 function calculateProofOfWork(Block storage blockData) private view returns (bytes32) {
    uint256 nonce = 0;
    bytes32 target = bytes32(uint256(2 ** (256 - difficulty)));

    while (true) {
        bytes32 hash = calculateHash(blockData, nonce);
        if (uint256(hash) <= uint256(target)) {
            return hash;  // Return the hash instead of setting it in block data.
        }
        nonce++;
    }
}                                              // Calculate the proof of work for a block
}
