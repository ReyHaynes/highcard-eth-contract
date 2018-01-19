pragma solidity ^0.4.19;

contract HighCardGame {

    // Game Contract Settings
    address public __owner;
    uint public __balancesDailyPrize;
    uint public __balancesGame;

    // Cost to play. Must send EXACT amount to be a valid play!
    uint constant __ethPerPlay = 0.005 ether;

    // 5% Used as Reserve for Daily Prize Raffle
    uint constant __ethDailyPrizeFee = (__ethPerPlay / 10) / 2;
    // 2.5% Used as Reserve for Transfer Fee & Contract Owner Cut
    uint constant __ethGameFee = __ethDailyPrizeFee / 2;
    // 2.5% Used as Refund to report Loss to Player
    uint public LOSS = __ethGameFee;
    // 90% Sent to winner!
    uint public WIN = (__ethPerPlay * 2) - __ethDailyPrizeFee - __ethGameFee - LOSS;


    // Game Storage
    address public playerMatch;
    uint8 public playerMatchNumber;

    /*  Game Constructor
     *
     *  A payable balance sent will be split between __balancesGame & __balancesDailyPrize
     *  Useful if you want to start your Game Contract with reserve and prize
     */
    function HighCardGame() public payable {
        playerMatch = address(0);
        if (msg.value > 0) {
            __balancesDailyPrize = msg.value / 2;
            __balancesGame = __balancesDailyPrize;
        }
    }

    function play() public payable returns (address _player1, address _player2, address _winner, address _loser) {
        // Exact ETH to play
        require(msg.value == __ethPerPlay);
        // Cannot be the previous player
        require(msg.sender != playerMatch);

        // Match Players
        // Ideally want to
        return _gameMatchPlay(msg.sender);
    }

    // Remix Helper (Can Delete)
    function getContractBalance() public view returns (uint) {
        return this.balance;
    }

    // Random Number Generator (Potential Problems)
    function _setRandomNumber(uint _cap) private view returns (uint8) {
        return uint8(uint(block.blockhash(block.number-1)) % _cap + 1);
    }

    function _gameMatchPlay(address _player) private returns (address, address, address, address) {
        // If Player Match Found = Play Game
        if (playerMatch != address(0)) {
            uint8 number = _setRandomNumber(13);
            address winner;
            address loser;
            if (number > playerMatchNumber) {
                winner = _player;
                loser = playerMatch;
            }
            else {
                loser = _player;
                winner = playerMatch;
            }
            address player1 = playerMatch;
            playerMatch = address(0);
            playerMatchNumber = 0;
            _playerTransfer(winner, WIN);
            _playerTransfer(loser, LOSS);
            // Ideally would return this when sending transfers
            return (player1, _player, winner, loser);
        }
        // If No Player Match = Wait For Next Player
        else {
            playerMatch = _player;
            playerMatchNumber = _setRandomNumber(13);
            return (playerMatch, address(0), address(0), address(0));
        }
    }

    // Transfer win/loss to players
    function _playerTransfer(address _to, uint _value) private {
        _to.transfer(_value);
        __balancesDailyPrize += __ethDailyPrizeFee;
        __balancesGame += __ethGameFee;
    }

}
