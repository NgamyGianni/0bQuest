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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract claim {

    struct Winner{
        uint lastGameLength;
    }

    uint public rewardAmountByGame;
    uint public rewardAmount;
    uint public currentRewardAmount;

    mapping(uint => int) public nbWinnersByIndex;
    mapping(address => Winner) public winners;
    uint public index;

    I0bOptions public ObContract;
    IERC20 public ObToken;

    constructor(){
        //ObContract = 0;
        ObToken = IERC20(0xB57ee0797C3fc0205714a577c02F7205bB89dF30);
        rewardAmountByGame = 1 * (10**18);
    }

    function addReward() external payable {
        uint amount = ObToken.allowance(msg.sender, address(this));

        require(ObToken.transferFrom(msg.sender, address(this), amount), 'Failed to send');

        rewardAmount += amount;
        currentRewardAmount += amount;
    }

    function getRewardGames() external {

        Winner storage user = winners[msg.sender];

        (bool win, uint games) = isWinnerGames(msg.sender);
        require(win, "You did not won a game since your last withdrawal");

        uint tmp = games - user.lastGameLength;
        user.lastGameLength = games;
        
        if(rewardAmount < tmp * (10**18)){
            require(rewardAmount > 0, "The contract is empty");

            bool txt = ObToken.transfer(msg.sender, rewardAmount);
            require(txt, 'Failed to send.');

            currentRewardAmount -= rewardAmount;
        }else{
            require(rewardAmount > 0, "The contract is empty");

            bool txt = ObToken.transfer(msg.sender, tmp * (10**18));
            require(txt, 'Failed to send.');

            currentRewardAmount -= tmp * (10**18);
        }
    }

    function isWinnerGames(address _address) public view returns (bool, uint) {
        // nb games

        //uint totalGames = ObContract.getUserGames(_address).length;
        Winner storage user = winners[_address];
        uint totalGames = user.lastGameLength + 10;

        uint tmp = totalGames - user.lastGameLength;

        uint cpt;
        
        if(tmp > 0){
            for(uint i=user.lastGameLength; i < totalGames; i++){
                /*(uint256 amount, , ) = ObContract.users(ObContract.userGames(_address, i), _address);
                if(amount >= 1 ether)   cpt++;*/
                cpt++;
            }

            return (tmp > 0 && cpt > 0, totalGames);
        }

        return (false, totalGames);
    }
    
}