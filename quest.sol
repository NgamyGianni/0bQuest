pragma solidity ^0.8.0;

interface I0bOptions {
    function initCycle() external;
    function NextCurrentGame() external;
    function joinUp() external payable;
    function joinDown() external payable;
    function reward(uint[] memory idGames) external;
    function rewardAdmin(address payable _address) external;
    function isWinner(uint idGame, address _address) external view returns(bool _isWinner);
    function getCurrentPrice() external view returns(int _price);
    function getUserGames(address _user) external view returns(uint[] memory games);
    function getUserAvailableWins(address _user) external view returns(uint[] memory _winGames);
    function getUserWins(address _user) external view returns(uint[] memory _winGames);
    function getUserTotalAmount(address _user) external view returns(uint amountGames);
    function getUserWinAmount(address _user) external view returns(uint _winAmount);
    function setIntervalSeconds(uint _intervalSeconds) external;

    function currentGameId() external view returns (uint);
    function Games(uint) external view returns (uint256, uint256, uint256, uint256, uint256, bool, uint256, int256);
    function users(uint, address) external view returns (uint256, uint8, bool);
    function userGames(address, uint256) external view returns (uint256);
}


contract questMatic {

    struct Winner{
        uint lastWinAmount;
        uint lastTotalAmount;
        uint lastGames;
        uint lastWins;
    }

    uint public rewardAmount;
    mapping(uint => int) public nbWinnersByIndex;
    mapping(address => Winner) public winners;
    uint public index;

    I0bOptions public ObContract;

    constructor(){
        //ObContract = 0;
    }

    function addReward() external payable {
        rewardAmount += msg.value;
    }

    function getRewardAmount() external {
        Winner storage user = winners[msg.sender];

        (bool win, uint amount) = isWinnerAmount(msg.sender);
        require(win, 'You did not achieve this quest');

        user.lastTotalAmount = amount;

        (bool sent, ) = msg.sender.call{value: 0.01 ether}("");
        require(sent, "Failed to send.");
    }

    function getRewardWinAmount() external {
        Winner storage user = winners[msg.sender];

        (bool win, uint amount) = isWinnerWinAmount(msg.sender);
        require(win, 'You did not achieve this quest');

        user.lastTotalAmount = amount;

        (bool sent, ) = msg.sender.call{value: 0.01 ether}("");
        require(sent, "Failed to send.");
    }

    function getRewardGames() external {
        Winner storage user = winners[msg.sender];

        (bool win, uint amount) = isWinnerGames(msg.sender);
        require(win, 'You did not achieve this quest');

        user.lastTotalAmount = amount;

        (bool sent, ) = msg.sender.call{value: 0.01 ether}("");
        require(sent, "Failed to send.");
    }

    function getRewardWins() external {
        Winner storage user = winners[msg.sender];

        (bool win, uint amount) = isWinnerWins(msg.sender);
        require(win, 'You did not achieve this quest');

        user.lastTotalAmount = amount;

        (bool sent, ) = msg.sender.call{value: 0.01 ether}("");
        require(sent, "Failed to send.");
    }

    function isWinnerAmount(address _address) public view returns (bool, uint) {
        // played amount

        //uint totalAmount = ObContract.getUserTotalAmount(_address);
        Winner storage user = winners[_address];
        uint totalAmount = user.lastTotalAmount + (10 ether);

        uint tmp = totalAmount - user.lastTotalAmount;

        return (tmp >= 10 ether, totalAmount);
    }

    function isWinnerWinAmount(address _address) public view returns (bool, uint) {
        // net winnings

        //uint totalWinAmount = ObContract.getUserWinAmount(_address);
        Winner storage user = winners[_address];
        uint totalWinAmount = user.lastWinAmount + (1 ether);

        uint tmp = totalWinAmount - user.lastWinAmount;

        return (tmp >= 10 ether, totalWinAmount);
    }

    function isWinnerGames(address _address) public view returns (bool, uint) {
        // nb games

        //uint totalGames = ObContract.getUserGames(_address).length;
        Winner storage user = winners[_address];
        uint totalGames = user.lastGames + 10;

        uint tmp = totalGames - user.lastGames;


        uint cpt;
        
        if(tmp >= 10){
            uint cpt;
            for(uint i=user.lastGames; i < totalGames; i++){
                (uint256 amount, , ) = ObContract.users(ObContract.userGames(_address, i), _address);
                if(amount >= 1 ether)   cpt++;
            }
        }

        return (tmp >= 10 && cpt >= 10, totalGames);
    }

    function isWinnerWins(address _address) public view returns (bool, uint) {
        // nb wins

        //uint totalWins = ObContract.getUserWins(_address).length;
        Winner storage user = winners[_address];
        uint totalWins = user.lastWins + 10;

        uint tmp = totalWins - user.lastWins;

        return (tmp >= 10, totalWins);
    }
    
}