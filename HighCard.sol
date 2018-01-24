pragma solidity ^0.4.19;

contract HighCardGame {

    // Game Contract Settings
    address public __owner;
    uint public __balancesDailyPrize;

    // Cost to play. Must send EXACT amount to be a valid play!
    uint constant __ethPerPlay = 0.01 ether;


    // Game Storage
    struct PlayerWaiting {
        address addr;
        uint8 card;
    }
    PlayerWaiting playerWaiting;

    /*  Game Constructor
     *
     *  A payable balance sent will be split between __balancesDailyPrize & Game Reserve
     *  Useful if you want to start your Game Contract with a reserve and prize
     */
    function HighCardGame() public payable {
        __owner = msg.sender;
        playerWaiting = PlayerWaiting(address(0), 0);

        if (msg.value > 0) {
            __balancesDailyPrize = msg.value / 2;
        }
    }

    function play() public payable {
        // Exact ETH to play
        require(msg.value == __ethPerPlay);
        // Cannot be the previous player
        require(msg.sender != playerWaiting.addr);

        address winner;
        address loser;
        bool gameOver;

        // Game Match
        (winner, loser, gameOver) = _gameMatchPlay(msg.sender);

        // Check Match
        if (gameOver) {
            // Send to Winner and Loser
            _playerTransfer(winner, loser);
        }
    }

    // Remix Helper (Can Delete)
    function getContractBalance() public view returns (uint) {
        return this.balance;
    }

    // Random Number Generator (Potential Problems)
    function _setRandomNumber(uint _cap) private view returns (uint8) {
        return uint8(uint(block.blockhash(block.number-1)) % _cap + 1);
    }

    function _gameMatchPlay(address _player) private returns (address, address, bool) {
        // If Player Match Found = Play Game
        if (playerWaiting.addr != address(0)) {
            uint8 number = _setRandomNumber(13);
            address winner;
            address loser;
            if (number > playerWaiting.card) {
                winner = _player;
                loser = playerWaiting.addr;
            }
            else {
                loser = _player;
                winner = playerWaiting.addr;
            }
            playerWaiting = PlayerWaiting(address(0), 0);
            return (winner, loser, true);
        }
        // If No Player Match = Wait For Next Player
        else {
            playerWaiting = PlayerWaiting(_player, _setRandomNumber(13));
            return (address(0), address(0), false);
        }
    }

    // Transfer win/loss to players
    function _playerTransfer(address _winner, address _loser) private {
        // 5% Used as Reserve for Daily Prize Raffle
        uint ethDailyPrizeFee = (__ethPerPlay / 10) / 2;
        // 2.5% Used as Contract Reserve for Gas Fees & Owner
        uint ethGameReserveFee = ethDailyPrizeFee / 2;
        // 2.5% Used as Refund to report Loss to Player
        uint LOSSREWARD = ethGameReserveFee;
        // 190% Sent to winner!
        uint WINREWARD = (__ethPerPlay * 2) - ethDailyPrizeFee - ethGameReserveFee - LOSSREWARD;

        _winner.transfer(WINREWARD);
        _loser.transfer(LOSSREWARD);
        __balancesDailyPrize += ethDailyPrizeFee;
    }

    // ABORT!! End Contract
    function endContract() public {
        if (msg.sender == __owner) {
            selfdestruct(__owner);
        }
    }

}
