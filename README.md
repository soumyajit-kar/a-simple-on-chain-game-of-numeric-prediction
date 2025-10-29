# 🎯 A Simple On-Chain Game of Numeric Prediction

Welcome to **A Simple On-Chain Game of Numeric Prediction** — a beginner-friendly Solidity project designed to help you learn how smart contracts work on the Ethereum blockchain.  

This game lets players **guess a secret number** stored on-chain. If they guess correctly, they **win the prize pool** in Ether!  

---

## 🧠 Project Description
<img width="1920" height="1080" alt="Screenshot 2025-10-29 141536" src="https://github.com/user-attachments/assets/2f7150b1-4401-486c-bedc-d0d49989fa88" />


This project demonstrates how to build an **interactive blockchain game** using **Solidity**, where players compete to guess a hidden number. It’s perfect for developers who are new to Ethereum smart contracts and want to explore concepts like:
- contract ownership  
- state variables  
- Ether transfers  
- events  
- simple game logic  

---
##the transition screenshot
![WhatsApp Image 2025-10-29 at 2 30 13 PM](https://github.com/user-attachments/assets/784d6eb5-4829-44ec-98d0-b082a0875aa7)


## 💡 What It Does

1. The **owner** starts a new game by funding the contract with Ether and setting a **winning number** (between 1–100).  
2. **Players** join the game and submit their guesses by calling the `makeGuess()` function.  
3. If a player guesses the correct number, they **win all the Ether** in the reward pool.  
4. The game ends automatically when someone wins, and the owner can **reset** it for the next round.  

---

## ✨ Features

- 🔒 **Owner-controlled game rounds** — only the contract owner can start or reset a game.  
- 💰 **On-chain reward pool** — all funds are handled transparently through the blockchain.  
- 🎲 **Simple guess mechanism** — players can make one guess per round.  
- 🏆 **Automatic payout** — the winner receives the Ether immediately upon guessing correctly.  
- 📜 **Event logs** — all actions (game start, guesses, winners) are emitted as blockchain events for easy tracking.  

---

## 🧱 Smart Contract Code

```solidity
//paste your code

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NumberPredictionGame {
    address public owner;
    uint256 private winningNumber; // secret number
    uint256 public rewardPool;     // total prize pool
    bool public gameActive;        // is the game running?

    mapping(address => bool) public hasGuessed; // prevent multiple guesses

    event GameStarted(uint256 rewardPool);
    event PlayerGuessed(address player, uint256 guess, bool won);
    event WinnerPaid(address winner, uint256 amount);
    event GameReset();

    constructor() {
        owner = msg.sender;
    }

    /// @notice Fund and start a new game
    function startGame(uint256 _winningNumber) external payable onlyOwner {
        require(!gameActive, "Game already running");
        require(msg.value > 0, "Must fund the reward pool");
        require(_winningNumber >= 1 && _winningNumber <= 100, "Number out of range");

        winningNumber = _winningNumber;
        rewardPool = msg.value;
        gameActive = true;

        emit GameStarted(rewardPool);
    }

    /// @notice Player submits a guess
    function makeGuess(uint256 _guess) external {
        require(gameActive, "Game not active");
        require(!hasGuessed[msg.sender], "Already guessed");
        require(_guess >= 1 && _guess <= 100, "Guess out of range");

        hasGuessed[msg.sender] = true;

        if (_guess == winningNumber) {
            gameActive = false;
            payable(msg.sender).transfer(rewardPool);
            emit PlayerGuessed(msg.sender, _guess, true);
            emit WinnerPaid(msg.sender, rewardPool);
        } else {
            emit PlayerGuessed(msg.sender, _guess, false);
        }
    }

    /// @notice Owner can reset the game for a new round
    function resetGame() external onlyOwner {
        require(!gameActive, "Finish current game first");
        rewardPool = 0;

        // reset all guesses (simple version — in real apps you'd use rounds or more efficient design)
        // For simplicity, we're not clearing the mapping — this is fine for a demo

        emit GameReset();
    }

    /// @notice Modifier for owner-only actions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @notice Allow contract to receive Ether
    receive() external payable {}
}

