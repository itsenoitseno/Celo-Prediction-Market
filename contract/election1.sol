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

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    enum Side { APC, PDP}
    struct Result {
        Side winner;
        Side loser; 
    }

    Result public result;
    bool public electionFinished;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;
    
    address public oracle;

    constructor(address _oracle){
        oracle = _oracle;
    }

    function placeBet(Side _side, uint256 betAmount) external payable {
        require(electionFinished == false, 'election is finished');
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                betAmount
            ),
            "Transfer failed"
        );
        bets[_side] = bets[_side].add(betAmount);
        betsPerGambler[msg.sender][_side] =  betsPerGambler[msg.sender][_side].add(betAmount) ;
        
    }

    function withdrawGain() external {
        uint gamblerBet = betsPerGambler[msg.sender][result.winner];
        require(gamblerBet > 0, 'you do not have any winning bet');
        require(electionFinished == true, 'election not finished');
        uint gain = gamblerBet + bets[result.loser] * gamblerBet / bets[result.winner]; 
        betsPerGambler[msg.sender][Side.APC] = 0;
        betsPerGambler[msg.sender][Side.PDP] = 0;
        IERC20Token(cUsdTokenAddress).transfer(msg.sender, gain);
        
    }

    function reportResult(Side _winner, Side _loser) external {
        require(oracle == msg.sender, 'only oracle');
        require(electionFinished == false, 'election is already finished');
        result.winner = _winner;
        result.loser = _loser;
        electionFinished = true;       
    }
}