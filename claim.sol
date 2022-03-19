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
    address public admin;

    mapping(uint => int) public nbWinnersByIndex;
    mapping(address => Winner) public winners;
    uint public index;

    I0bOptions public ObContract;
    IERC20 public ObToken;

    event AddReward(address indexed admin, uint amount);
    event GetRewardGames(address indexed from, uint amount);

    constructor(){
        ObContract = I0bOptions(0x8862090A79412D034d9Fb8C9DBFd3194C8D2a2EE);
        ObToken = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
        rewardAmountByGame = 10 * (10**18);
        admin = msg.sender;
    }

    function addReward() external payable {
        uint amount = ObToken.allowance(msg.sender, address(this));

        require(ObToken.transferFrom(msg.sender, address(this), amount), 'Failed to send.');

        rewardAmount += amount;
        currentRewardAmount += amount;

        emit AddReward(msg.sender, amount);
    }

    function getRewardGames() external {

        Winner storage user = winners[msg.sender];

        (bool win, uint games) = isWinnerGames(msg.sender);
        require(win, "You did not won a game since your last withdrawal");

        uint pendingLength = games - user.lastGameLength;
        user.lastGameLength = games;
        
        if(rewardAmount < pendingLength * (10**18)){
            require(rewardAmount > 0, "The contract is empty");

            bool t = ObToken.transfer(msg.sender, rewardAmount);
            require(t, 'Failed to send.');

            currentRewardAmount -= rewardAmount;
        }else{
            require(rewardAmount > 0, "The contract is empty");

            bool t = ObToken.transfer(msg.sender, pendingLength * (10**18));
            require(t, 'Failed to send.');

            currentRewardAmount -= pendingLength * (10**18);
        }

        emit GetRewardGames(msg.sender, pendingLength * (10**18));
    }

    function isWinnerGames(address _address) public view returns (bool, uint) {
        // nb games

        uint totalGames = ObContract.getUserGames(_address).length;
        Winner storage user = winners[_address];
        //uint totalGames = user.lastGameLength + 10;

        uint pendingLength = totalGames - user.lastGameLength;

        uint cpt;
        
        if(pendingLength > 0){
            for(uint i=user.lastGameLength; i < totalGames; i++){
                (uint256 amount, , ) = ObContract.users(ObContract.userGames(_address, i), _address);
                if(amount >= 1 ether)   cpt++;
                //cpt++;
            }

            return (pendingLength > 0 && cpt > 0, totalGames);
        }

        return (false, totalGames);
    }
    
}