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
