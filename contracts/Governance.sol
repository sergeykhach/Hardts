// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol'; //petqa vor token enq unenum vory priyazka enq anum golosi hamar

contract Governance {
    struct ProposalVote { //pahum en qgolosiu ardyunqnery
        uint againstVotes; //dem
        uint forVotes; //koghm
        uint abstainVotes; //dzernpah
        mapping(address => bool) hasVoted; //konkret hascen golos arel a te che
    }

    struct Proposal { // es el erb a sksum erb avartvum avartvac a te che
        uint votingStarts;
        uint votingEnds;
        bool executed;
    }
//stati vichaknerna
    enum ProposalState { Pending, Active, Succeeded, Defeated, Executed } // chi sksvac, sksvac a , hajogha.... Executed-pritvoreno v jizn

    mapping(bytes32 => Proposal) public proposals; //Idneri hamarnerov arajarknerov
    mapping(bytes32 => ProposalVote) public proposalVotes; //golosneri informacian

    IERC20 public token;
    uint public constant VOTING_DELAY = 10; //jamanak 
    uint public constant VOTING_DURATION = 60; //karch a shat ughaki dem-i hamar

    event ProposalAdded(bytes32 proposalId);

    constructor(IERC20 _token) {
        token = _token; //asum enq es token a golos-i hamar
    }

//arajark nerkayacnelu funkcian golosi hamar
    function propose(
        address _to, //ur enq ugharkum
        uint _value, //poghi chapy
        string calldata _func,
        bytes calldata _data, //tvyalnery vor uzum enq ugharkel
        string calldata _description //arajarki eutyuny
    ) external returns(bytes32) {
        require(token.balanceOf(msg.sender) > 0, "not enough tokens"); //ov uni kara golos uni

        bytes32 proposalId = generateProposalId(// arajarki ID-n vor imananq konkret vior arajarki hamar en qgolos anum
            _to, _value, _func, _data, keccak256(bytes(_description))//discr-y hash enq anum
        );

        require(proposals[proposalId].votingStarts == 0, "proposal already exists"); //nuyn banery petq chi lini

        proposals[proposalId] = Proposal({
            votingStarts: block.timestamp + VOTING_DELAY,//erba sksum
            votingEnds: block.timestamp + VOTING_DELAY + VOTING_DURATION,// erba avartvum
            executed: false //avartvel a ? default
        });

        emit ProposalAdded(proposalId);

        return proposalId;
    }

//asum  inq irakanacra progolosovani haghtac proposaly
    function execute(
        address _to, //mihat ek nuyn banery
        uint _value,
        string calldata _func,
        bytes calldata _data,
        bytes32 _descriptionHash// nkaragrutyan hash
    ) external returns(bytes memory) {
        bytes32 proposalId = generateProposalId( //asum enq vor irakanum eghela senc proposal u golosa eghel
            _to, _value, _func, _data, _descriptionHash
        );

        require(state(proposalId) == ProposalState.Succeeded, "invalid state");//hajogha eghel

        Proposal storage proposal = proposals[proposalId];

        proposal.executed = true; 

        bytes memory data;
        if (bytes(_func).length > 0) { //asum enq ete _func ka  uremn
            data = abi.encodePacked( // apa ed funkciayi anuny hash enq anum u
                bytes4(keccak256(bytes(_func))), _data //vercnum enq arajin 4 byte
            );
        } else {
            data = _data; // hakarak depqum inch ka
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);
        require(success, "tx failed"); //ugharkumenq nizko urovni

        return resp; 
    }

//inchpes golos anennq
    function vote(bytes32 proposalId, uint8 voteType) external {
        require(state(proposalId) == ProposalState.Active, "invalid state");//asum enq pti state aktiv lini

        uint votingPower = token.balanceOf(msg.sender);// parz realizacia hzorutyan ysk tokenneri qanaki vortev, kara ira mi hasceyic myus gci au amen angam hzor golos ani, dra hamar zep-um jamanaki koncept ka check point

        require(votingPower > 0, "not enough tokens");// asum enq gone mi qich token pti unenas 

        ProposalVote storage proposalVote = proposalVotes[proposalId];//id-ov gtnum  enq proposaly vor vote anenq

        require(!proposalVote.hasVoted[msg.sender], "already voted");//asum enq vor mi angam voted ani

        if(voteType == 0) { //asum enq ete 0ya urmen dema 
            proposalVote.againstVotes += votingPower; // u avelacnum enq yst dra
        } else if(voteType == 1) {//1 a uremn koghma 
            proposalVote.forVotes += votingPower;
        } else {
            proposalVote.abstainVotes += votingPower;
        }

        proposalVote.hasVoted[msg.sender] = true;//asum enq vor arden golos arel a
    }

//stugum enq ardyoq golosovaniyan sksel a
    function state(bytes32 proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        ProposalVote storage proposalVote = proposalVotes[proposalId];
//stugum enq ka te che tenc arajark
        require(proposal.votingStarts > 0, "proposal doesnt exist");

        if (proposal.executed) {
            return ProposalState.Executed;
        }//arden arvac

        if (block.timestamp < proposal.votingStarts) {
            return ProposalState.Pending;
        }//hly chi skasac

        if(block.timestamp >= proposal.votingStarts &&
            proposal.votingEnds > block.timestamp) {
            return ProposalState.Active;
        }//yntacqi mej a

        //stegh karanq qvorum i mekhanizm dneinq
        if(proposalVote.forVotes > proposalVote.againstVotes) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }//prcela kam yndunvela ka voch
    }

//esi henc konkret arajarki Id-n enq generacnum
    function generateProposalId(
        address _to,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        bytes32 _descriptionHash
    ) internal pure returns(bytes32) {
        return keccak256(abi.encode(
            _to, _value, _func, _data, _descriptionHash
        ));
    }

    receive() external payable {}
}

