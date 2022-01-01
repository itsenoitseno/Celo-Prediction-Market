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

contract PredictionMarket {

    uint internal contestantsLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

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

    // add vandidate data
    function addCandidateData(
        string memory _contestantName,
        uint256 _placedBets,
        string memory _contestantImage,
        uint _noOfStakes,
        address[] memory _stakers,
        uint256[] memory _amountStaked,
        bool _isWinner
    ) public {
        _isWinner = false;
        Side _side = Side.Contestant1;
        contestantsData[_side] = contestantDataTemplate(
            _contestantName,
            _placedBets,
            _contestantImage,
            _noOfStakes,
            _stakers,
            _amountStaked,
            _isWinner
        );
        contestantsLength++;
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

    function placeBet(Side _side, uint256 stakeAmount) public payable {
        require(electionFinished == false, 'election is finished');
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                stakeAmount
            ),
            "Transfer failed"
        );

        contestantDataTemplate storage _data = contestantsData[_side];
            _data.placedBets += stakeAmount;
            _data.noOfStakes++;
            _data.stakers.push(msg.sender);
            _data.amountStaked.push(stakeAmount);
    
        betsPerGambler[msg.sender][_side] += stakeAmount;
        hasStaked[msg.sender][_side] = true;
        totalNoOfStakes++;
    }

    function getUserStakes(Side _side) public view returns(uint){
        return(betsPerGambler[msg.sender][_side]);
    }

    function isStaker(Side _side) public view returns(bool){
        return(hasStaked[msg.sender][_side]);
    } 

    function declareWinner(Side _winner) onlyOracle() public {
        require(electionFinished == false, 'election is already finished');
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

        uint256 gain = gamblerBet + losses * gamblerBet / contestantsData[result.winner].placedBets; 

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