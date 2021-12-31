// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

contract PredictionMarket {

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    using SafeMath for uint;
    enum Side {
        Contestant1,
        Contestant2,
        Contestant3,
        Contestant4,
        Contestant5
    }

    struct contestantDataTemplate {
        string contestantName;
        uint256 placedBets;
        string contestantImage;
        uint noOfStakes;
        address[] stakers;
        uint256[] amountStaked;
        bool isWinner;
    }

    struct Result {
        Side winner;
    }



    Result result;
    bool public electionFinished;


    // mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) betsPerGambler;

    mapping(address => mapping(Side => bool)) hasStaked;

    //To keep record of the contestant data
    mapping(Side => contestantDataTemplate) contestantsData;

    address public oracle;
    uint noOfContestants;
    string[] contestants;
    string[] contestantImages;
    string marketTopic;
    uint totalNoOfStakes;

    //Modifiers

    modifier onlyOracle() {
        // i.e function can only be activated after the time runs out
        require(oracle == msg.sender, "Sorry you do not have access to this function");
        _;
    }

    modifier electionIsFinished()
    {
        require(electionFinished == false, 'election is finished');
        _;
    }
    constructor(address _oracle, string memory _marketTopic, uint _noOfContestants, string[] memory _contestants, string[] memory _contestantImages){
        oracle = _oracle;
        marketTopic = _marketTopic;
        noOfContestants = _noOfContestants;
        contestants = _contestants;
        contestantImages = _contestantImages;
        //Create market.
        createMarket();
    }

    function createMarket() internal {
        require(noOfContestants <= 5, 'Maximum of 5 contestants allowed');

        Side _contestant;
        for(uint n = 0; n < noOfContestants; n++){
            if (n == 0) {
                _contestant = Side.Contestant1;
            }else if (n == 1){
                _contestant = Side.Contestant2;
            }else if (n == 2){
                _contestant = Side.Contestant3;
            }else if (n == 3){
                _contestant = Side.Contestant4;
            }else if (n == 4){
                _contestant = Side.Contestant5;
            }

            contestantDataTemplate storage _data = contestantsData[_contestant];
            _data.contestantName = contestants[n];
            _data.contestantImage = contestantImages[n];
        }
    }

    function getTopic() public view returns(string memory){
        return(marketTopic);
    }

    function getNoOfContestants() public view returns(uint){
        return(noOfContestants);
    }

    function getCandidatesData(Side _side) public view returns(
        string memory,
        uint256,
        string memory,
        uint,
        address[] memory,
        uint256[] memory,
        bool
    ){  contestantDataTemplate storage _data = contestantsData[_side];

        return (
        _data.contestantName,
        _data.placedBets,
        _data.contestantImage,
        _data.noOfStakes,
        _data.stakers,
        _data.amountStaked,
        _data.isWinner
        );
    }

    function placeBet(Side _side, uint256 stakeAmount) public payable electionIsFinished {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                stakeAmount
            ),
            "Transfer failed"
        );

        contestantDataTemplate storage _data = contestantsData[_side];
        _data.placedBets =  _data.placedBets.add(stakeAmount);
        _data.noOfStakes.add(1);
        _data.stakers.push(msg.sender);
        _data.amountStaked.push(stakeAmount);

        betsPerGambler[msg.sender][_side] =  betsPerGambler[msg.sender][_side].add(stakeAmount);
        hasStaked[msg.sender][_side] = true;
        totalNoOfStakes++;
    }

    function getUserStakes(Side _side) public view returns(uint){
        return(betsPerGambler[msg.sender][_side]);
    }

    function isStaker(Side _side) public view returns(bool){
        return(hasStaked[msg.sender][_side]);
    }

    function declareWinner(Side _winner) onlyOracle() public  electionIsFinished {
        result.winner = _winner;
        electionFinished = true;

        contestantDataTemplate storage _data = contestantsData[_winner];
        _data.isWinner = true;
    }

    function withdrawGain() public {
        uint256 gamblerBet = betsPerGambler[msg.sender][result.winner];

        require(gamblerBet > 0, 'you do not have any winning bet');
        require(electionFinished == true, 'election not finished');

        uint256 losses;

        for(uint n = 0; n < noOfContestants; n++){
            Side _contestant;
            if (n == 0) {
                _contestant = Side.Contestant1;
            }else if (n == 1){
                _contestant = Side.Contestant2;
            }else if (n == 2){
                _contestant = Side.Contestant3;
            }else if (n == 3){
                _contestant = Side.Contestant4;
            }else if (n == 4){
                _contestant = Side.Contestant5;
            }

            if(_contestant != result.winner){
                losses += contestantsData[_contestant].placedBets;
            }
        }

        uint256 gain = gamblerBet.add(losses.mul(gamblerBet.div(contestantsData[result.winner].placedBets)));

        require(IERC20Token(cUsdTokenAddress).transfer(msg.sender, gain), 'Transfer Failed');

        // Reset bets record for each user.
        betsPerGambler[msg.sender][Side.Contestant1] = 0;
        betsPerGambler[msg.sender][Side.Contestant2] = 0;
        betsPerGambler[msg.sender][Side.Contestant3] = 0;
        betsPerGambler[msg.sender][Side.Contestant4] = 0;
        betsPerGambler[msg.sender][Side.Contestant5] = 0;

        //Reset staking Boolean.
        hasStaked[msg.sender][Side.Contestant1] = false;
        hasStaked[msg.sender][Side.Contestant2] = false;
        hasStaked[msg.sender][Side.Contestant3] = false;
        hasStaked[msg.sender][Side.Contestant4] = false;
        hasStaked[msg.sender][Side.Contestant5] = false;
    }
}