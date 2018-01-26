pragma solidity 0.4.19;


contract HighCardGame {
    // Game Contract Settings
    // Cost to play. Must send EXACT amount to be a valid play!
    uint public constant PLAYCOST = 0.01 ether;

    // Game Storage
    address public owner;
    uint public prizePool;
    uint private game;
    mapping (uint => GameData) public games;

    struct GameData {
        address p1;         // Set By P1
        address p2;         // Set By P2
        uint time;          // Set By P2
        uint block;         // Set By P2
        address coinbase;   // Set By P1
        uint8 reach;        // Set By P1
    }

    /*  Game Constructor
     *
     *  A payable balance sent will be split between prizePool & Game Reserve
     *  Useful if you want to start your Game Contract with a reserve and prize
     */
    function HighCardGame() public payable {
        owner = msg.sender;
        if (msg.value > 0) {
            prizePool = msg.value / 2;
        }
    }

    function play() public payable {
        // Exact ETH to play
        require(msg.value == PLAYCOST);
        // Cannot play against self
        require(msg.sender != games[game].p1);

        address winner;
        address loser;
        bool gameMatch;

        // Game Match
        (winner, loser, gameMatch) = _gameMatchPlay(msg.sender);

        // Check Match
        if (gameMatch == true) {
            // Send to Winner and Loser
            _playerTransfer(winner, loser);
            game++;
        }
    }

    function verifyGameDraw(uint _game) public view returns (uint8 player1, uint8 player2) {
        uint8 p1;
        uint8 p2;

        (p1, p2) = _getRandomNumbers(
            1, 13,
            games[_game].p1, games[_game].p2,
            games[_game].time,
            games[_game].coinbase, games[_game].block,
            games[_game].reach
        );

        return (p1, p2);
    }

    // ABORT!! End Contract
    function endContract() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function _getRandomNumber(uint _cap) private view returns (uint8) {
        bytes32 seed = keccak256(block.blockhash(block.number-1), now);
        return uint8(uint(seed) % _cap + 1);
    }

    function _getRandomNumbers(
        uint _min, uint _max,
        address _p1, address _p2,
        uint _time, address _coinbase, uint _num, uint _reach
    ) private view returns (uint8, uint8) {
        require(_reach > 0 && _reach < 65);
        uint seed1 = uint(keccak256(_p1, block.blockhash(_num-(_reach*1)), _num, _time)) % _max + _min;
        uint seed2 = uint(keccak256(_p2, block.blockhash(_num-(_reach*4)), _coinbase, _time)) % _max + _min;

        return (uint8(seed1), uint8(seed2));
    }

    function _gameMatchPlay(address _player) private returns (address, address, bool) {
        // If Player Match Found = Play Game
        if (games[game].p1 != 0x0) {
            uint8 p1num;
            uint8 p2num;
            address winner;
            address loser;
            uint timestamp = now;

            // Set Cards
            (p1num, p2num) = _getRandomNumbers(
                1, 13,
                games[game].p1, _player,
                timestamp,
                games[game].coinbase, block.number,
                games[game].reach
            );

            // Game Logic
            if (p2num > p1num) {
                winner = _player;
                loser = games[game].p1;
            } else {
                loser = _player;
                winner = games[game].p1;
            }

            games[game].p2 = _player;
            games[game].time = timestamp;
            games[game].block = block.number;

            return (winner, loser, true);
        } else {
            // If No Player Match = Start New Game
            games[game].p1 = _player;
            games[game].coinbase = block.coinbase;
            games[game].reach = _getRandomNumber(64);

            return (0x0, 0x0, false);
        }
    }

    // Transfer win/loss to players
    function _playerTransfer(address _winner, address _loser) private {
        // 5% Used as Reserve for Daily Prize Raffle
        uint ethDailyPrizeFee = (PLAYCOST / 10) / 2;
        // 2.5% Used as Contract Reserve for Gas Fees & Owner
        uint ethGameReserveFee = ethDailyPrizeFee / 2;
        // 2.5% Used as Refund to report Loss to Player
        uint lossReward = ethGameReserveFee;
        // 190% Sent to winner!
        uint winReward = (PLAYCOST * 2) - ethDailyPrizeFee - ethGameReserveFee - lossReward;

        _winner.transfer(winReward);
        _loser.transfer(lossReward);
        prizePool += ethDailyPrizeFee;
    }
}
