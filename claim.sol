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


contract claim {

    struct Winner{
        uint lastGameIndex;
    }

    uint public rewardAmountByGame;
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

    function getRewardGames() external {

        Winner storage user = winners[msg.sender];

        (bool win, uint games) = isWinnerGames(msg.sender);
        require(win, 'You did not achieve this quest');

        uint tmp = games - user.lastGameIndex;
        user.lastGameIndex = games;

        require(rewardAmount > tmp * (10**18), 'broke');

        (bool sent, ) = msg.sender.call{value: tmp * (10**18)}("");
        require(sent, "Failed to send.");
    }

    function isWinnerGames(address _address) public view returns (bool, uint) {
        // nb games

        //uint totalGames = ObContract.getUserGames(_address).length;
        Winner storage user = winners[_address];
        uint totalGames = user.lastGameIndex + 10;

        uint tmp = totalGames - user.lastGameIndex;

        uint cpt;
        
        if(tmp > 0){
            for(uint i=user.lastGameIndex; i < totalGames; i++){
                /*(uint256 amount, , ) = ObContract.users(ObContract.userGames(_address, i), _address);
                if(amount >= 1 ether)   cpt++;*/
                cpt++;
            }

            return (tmp > 0 && cpt > 0, totalGames);
        }

        return (false, totalGames);
    }
    
}