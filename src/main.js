import Web3 from 'web3'
import {
  newKitFromWeb3
} from '@celo/contractkit'
import BigNumber from "bignumber.js"
import predictionMarketAbi from '../contract/predictionMarket.abi.json'
import erc20Abi from "../contract/erc20.abi.json"
import {cUSDContractAddress, ERC20_DECIMALS, PMContractAddress} from "./utils/constants";



let candidates = []
let contract
let kit
let oracle
let hasElectionEnded
let isOracle


//For Constructor
//0x2E940012169Eb38703eB5a87aDBfDe372910Cf9d
//"Who will win the 59th United States Presidential Election"
//2
//["Donald Trump", "Joe Biden"]
//["https://dynaimage.cdn.cnn.com/cnn/c_fill,g_auto,w_1200,h_675,ar_16:9/https%3A%2F%2Fcdn.cnn.com%2Fcnnnext%2Fdam%2Fassets%2F170102084935-donald-trump-new-portrait.jpg", "https://www.whitehouse.gov/wp-content/uploads/2021/04/P20210303AS-1901-cropped.jpg"]


function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

const connectCeloWallet = async function() {
  if (window.celo) {
    notification("⚠️ Please approve this DApp to use it.")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(predictionMarketAbi, PMContractAddress)

      oracle = await contract.methods.oracle().call();
      hasElectionEnded = await contract.methods.electionFinished().call();


      if (kit.defaultAccount == oracle) {
        isOracle = true;
        $("#reportResult").removeClass('hidden');
      }

    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}

async function approve(_price) {
  const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

  const result = await cUSDContract.methods
    .approve(PMContractAddress, _price)
    .send({
      from: kit.defaultAccount
    })
  return result
}


const getBalance = async function() {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}


const getContestants = async function() {
  const _noOfCandidates = await contract.methods.getNoOfContestants().call();
  const _candidates = [];

  const _topic = await contract.methods.getTopic().call();

  document.querySelector("#topic").textContent = _topic.toUpperCase();

  for (let i = 0; i < _noOfCandidates; i++) {
    let _candidate = new Promise(async (resolve, reject) => {
      let p = await contract.methods.getCandidatesData(i).call()
      let q = await contract.methods.getUserStakes(i).call()
      let r = await contract.methods.isStaker(i).call()
      resolve({
        id: i,
        name: p[0],
        placedBets: new BigNumber(p[1]),
        image: p[2],
        noOfStakes: p[3],
        stakers: p[4],
        stakeAmounts: p[5],
        isWinner: p[6],
        userStakes: new BigNumber(q),
        userHasStaked: r,
      })
    })
    _candidates.push(_candidate)
  }
  candidates = await Promise.all(_candidates);
  renderCandidates();
}

function renderCandidates() {
  document.getElementById("gallery").innerHTML = ""
  candidates.forEach((_candidate) => {
    const newDiv = document.createElement("div")
    newDiv.className = "col-md-4"
    newDiv.innerHTML = candidateTemplate(_candidate)
    document.getElementById("gallery").appendChild(newDiv)
    modalEdit(_candidate)
  })
}

function candidateTemplate(_candidate) {
  return `
    <div class="card mb-2" style="padding:20px">
      <img class="card-img-top" src="${_candidate.image}" alt="...">
      <div id=ribbon${_candidate.id} class="position-absolute hidden" style="top:68%; right:15px;">
        <img width="60" height="70" src="https://www.seekpng.com/png/detail/28-288866_congratulations-ribbon-png-blue-ribbon-winner.png" >
      </div>
      <div class="position-absolute top-0 end-0 bg-warning mt-4 px-2 py-1 rounded-start">
        ${_candidate.noOfStakes} Stakes
      </div>
      <div class="card-body text-center p-4 position-relative">
        <h2 class="card-title fs-4 fw-bold mt-2">${_candidate.name.toUpperCase()}</h2>
        <span>CANDIDATE ID: ${_candidate.id}</span><br>
        <span id=_${_candidate.id} class="hidden"> YOUR STAKE : ${_candidate.userStakes.shiftedBy(-ERC20_DECIMALS).toFixed(2)}cUSD</span>       
        <div class="d-grid gap-2">
          <a class="btn btn-lg btn-outline-dark viewCandidate fs-6 p-3" id=${
            _candidate.id
          }>
            PLACE BET
          </a>
        </div>
      </div>
    </div>
  `
}

function modalEdit(_candidate) {
  if (isOracle) {
    $('#' + `${_candidate.id}`).removeClass('viewCandidate');
    $('#' + `${_candidate.id}`).addClass('viewStakes');
    $('#' + `${_candidate.id}`).contents().filter(function() {
      return this.nodeType == 3
    }).each(function() {
      this.textContent = this.textContent.replace('PLACE BET', 'VIEW STAKES');
    });
  } else {
    if (hasElectionEnded) {
      if(_candidate.isWinner){
        $('#ribbon' + `${_candidate.id}`).removeClass('hidden');
      }
      $('#_'+`${_candidate.id}`).removeClass('hidden');
      if (_candidate.userHasStaked && _candidate.isWinner) {
        $('#' + `${_candidate.id}`).removeClass('viewCandidate');
        $('#' + `${_candidate.id}`).addClass('claimReward');
        $('#' + `${_candidate.id}`).contents().filter(function() {
          return this.nodeType == 3
        }).each(function() {
          this.textContent = this.textContent.replace('PLACE BET', 'CLAIM REWARD');
        });
      } else if (_candidate.userHasStaked && !_candidate.isWinner) {
          $('#' + `${_candidate.id}`).addClass('disabled');
          $('#' + `${_candidate.id}`).contents().filter(function() {
            return this.nodeType == 3
          }).each(function() {
            this.textContent = this.textContent.replace('PLACE BET', 'YOU LOST');
          });
      } else {
        $('#' + `${_candidate.id}`).addClass('disabled');
        $('#' + `${_candidate.id}`).contents().filter(function() {
          return this.nodeType == 3
        }).each(function() {
          this.textContent = this.textContent.replace('PLACE BET', 'BET ENDED');
        });
      }
    }
  }
}

function renderBettingModal(id) {
  notification("⌛ Loading...");
  document.getElementById("bettingModalDisplay").innerHTML = ""
  const newDiv = document.createElement("div")
  newDiv.className = "modal-content"
  newDiv.innerHTML = bettingModalTemplate(candidates[id])
  document.getElementById("bettingModalDisplay").appendChild(newDiv)
  $("#betModal").modal('show');
  notificationOff()
}

function bettingModalTemplate(_candidate) {
  return `
  <div class="modal-content">
    <div class="modal-header">
        <h5 class="modal-title" id="placeBetModal">Place Bet</h5>
        <button
        type="button"
        class="btn-close"
        data-bs-dismiss="modal"
        aria-label="Close"
        ></button>
    </div>
    <div class="modal-body">
        <div>
          <div class="card mb-2" style="padding: 10px">
            <img class="card-img-top" src="${_candidate.image}" alt="...">
          </div>
          <div style="padding: 10px">
            <span> YOUR STAKES : ${_candidate.userStakes.shiftedBy(-ERC20_DECIMALS).toFixed(2)} cUSD</span>       
          </div>
          <form>
              <div class="col">
                <input
                    type="number"
                    id="bet"
                    class="form-control mb-2"
                    placeholder="Enter amount to bet in cUSD"
                />
                <button type="button" class="btn btn-dark placeBet" id=${
                  _candidate.id
                }>
                  PLACE BET
                </button>
              </div>
          </form>
        </div>
    </div>
    <div class="modal-footer">
        <button
        type="button"
        class="btn btn-light border"
        data-bs-dismiss="modal"
        >
        Close
        </button>
    </div>
  </div>
  `
}

function renderStakesModal(id) {
  notification("⌛ Loading...");

  document.querySelector("#stakeNumber").textContent = candidates[id].placedBets.shiftedBy(-ERC20_DECIMALS).toFixed(2);
  printTable(candidates[id])

  $("#stakeModal").modal('show');
  notificationOff()
}

function printTable(_candidate) {
  const table = document.querySelector("#stakeTable");

  //To clear table on each reload
  let rowCount = table.rows.length;
  for (let i = rowCount - 1; i > 0; i--) {
    table.deleteRow(i);
  }

  let stakers = _candidate.noOfStakes;
  for (let i = 0; i < stakers; i++) {
    let newRow = table.insertRow(-1);5
    let newCell1 = newRow.insertCell(0);
    let newCell2 = newRow.insertCell(1);

    newCell1.innerHTML = identiconTemplate(_candidate.stakers[i])
    newCell2.innerHTML = `${new BigNumber(_candidate.stakeAmounts[i]).shiftedBy(-ERC20_DECIMALS).toFixed(2)}cUSD`;
  }
}

function identiconTemplate(_address) {
  const icon = blockies
    .create({
      seed: _address,
      size: 8,
      scale: 16,
    })
    .toDataURL()

  return `
    <div class="rounded-circle overflow-hidden d-inline-block border border-white border-2 shadow-sm m-0">
      <a href="https://alfajores-blockscout.celo-testnet.org/address/${_address}/transactions"
          target="_blank">
          <img src="${icon}" width="48" alt="${_address}">
      </a>
    </div>
    `
}

document.querySelector("#gallery").addEventListener("click", async (e) => {
  let candidateID;

  if (e.target.className.includes("viewCandidate")) {
    candidateID = e.target.id;
    renderBettingModal(candidateID);
  }
  if (e.target.className.includes("viewStakes")) {
    candidateID = e.target.id;
    renderStakesModal(candidateID);
  }
  if (e.target.className.includes("claimReward")) {
    candidateID = e.target.id;

    try {
      const result = await contract.methods
        .withdrawGain()
        .send({
          from: kit.defaultAccount
        })
      notification(`🎉 Success".`)
      setTimeout(function() {
        notificationOff();
      }, 1500);
      getBalance();
      getContestants();
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }

  }
})

document.querySelector("#bettingModalDisplay").addEventListener("click", async (e) => {
  if (e.target.className.includes("closeModal")) {
    $('#betModal').modal('hide');
  }

  if (e.target.className.includes("placeBet")) {
    $('#betModal').modal('hide');
    const ID = e.target.id;
    console.log(ID)
    console.log(candidates[ID])
    const amount = new BigNumber(document.getElementById("bet").value).shiftedBy(ERC20_DECIMALS).toString();

    let isApproved = true;

    notification("⌛ Waiting for bid approval...")
    try {
      await approve(amount)
    } catch (error) {
      notification(`⚠️ ${error}.`)
      isApproved = false;
    }
    if(isApproved){
      notification(`⌛ Awaiting bid submission for "${candidates[ID].name}"...`)
      try {
        const result = await contract.methods
          .placeBet(ID, amount)
          .send({
            from: kit.defaultAccount
          })
        notification(`🎉 Bet successfully placed for"${candidates[ID].name}".`)
        setTimeout(function() {
          notificationOff();
        }, 1500);
        getBalance();
        getContestants();
      } catch (error) {
        notification(`⚠️ ${error}.`)
      }
    }
  }
})

document.querySelector("#submitBtn").addEventListener("click", async (e) => {
    const winnerID = document.getElementById("winner").value;
    $('#stakeModal').modal('hide');
    notification(`⌛ Declaring ${candidates[winnerID].name} as Winner...`)
    try {
      const result = await contract.methods
        .declareWinner(winnerID)
        .send({
          from: kit.defaultAccount
        })
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification(`🎉 Winner Declared.`);
    setTimeout(function() {
      notificationOff();
    }, 1500);
    getContestants();
  })

window.addEventListener('load', async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getContestants()
  notificationOff()
});
