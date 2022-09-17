// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

import "hardhat/console.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Election {

    address private electionComissioner;

    //Defining party structure
    struct politicalParty 
    {
        string name;
        string symbol;
        uint64 votes;
    }
    
    // mapping party ID to Struct
    mapping (address => politicalParty) Party;

    // Defining eligible voter
    struct voter{
        bool isEligible;
        bool hasVoted;
    }
    // mapping party ID to Struct
    mapping (address => voter) Voter;
    uint256 [] ballot_log;
    uint256 [] voting_receipt_book;


    // event for EVM logging
    event Set_electionComissioner(address indexed old_electionComissioner, address indexed new_electionComissioner);
    event vote_Casted(address indexed address_politicalParty);
    event new_partyAdded(address indexed address_politicalParty);

    // modifier to check if caller is owner
    modifier is_electionComissioner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == electionComissioner, "Caller is not the electionComissioner");
        _;
    }

    modifier is_validVoter(){
        require(Voter[msg.sender].isEligible == true, "Candidate is not an eligible voter");
        require(Voter[msg.sender].hasVoted == false, "Candidate has already voted");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() public {
        console.log("Assembly Election Contract Deployed by -> ", msg.sender);
        electionComissioner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit Set_electionComissioner(address(0), electionComissioner);
    }

    /**
     * @dev Change owner
     * @param new_electionComissioner address of new owner
     */
    function change_electionComissioner(address new_electionComissioner) public is_electionComissioner {
        emit Set_electionComissioner(electionComissioner, new_electionComissioner);
        electionComissioner = new_electionComissioner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function get_electionComissioner() external view returns (address) {
        return electionComissioner;
    }

    function add_PoliticalParty(address address_politicalParty, string calldata name,string calldata symbol,uint64 votes) public is_electionComissioner {
        Party[address_politicalParty].name = name;
        Party[address_politicalParty].symbol = symbol;
        Party[address_politicalParty].votes = votes;
        emit new_partyAdded(address_politicalParty);

    }

    function unlock_votingRight(address anonymised_voter) public {
        Voter[anonymised_voter].isEligible = true;
        Voter[anonymised_voter].hasVoted = false;
        console.log(" Voting Right Unlocked from Contract-> ", msg.sender);
        console.log(" Voting Right Unlocked for user -> ", anonymised_voter);
    }

    function get_PoliticalParty(address address_politicalParty) external view returns(string memory,string memory ,uint64){
        return(Party[address_politicalParty].name,Party[address_politicalParty].symbol,Party[address_politicalParty].votes);
    }

    function castVote(address address_politicalParty, uint256 n2) public is_validVoter {
        Party[address_politicalParty].votes = Party[address_politicalParty].votes + 1;
        Voter[msg.sender].isEligible = false;
        Voter[msg.sender].hasVoted = true;
        ballot_log.push(n2); 
        //Destroy the verification Contract
        emit vote_Casted(address_politicalParty);
    }

    function populate_successful_votes(uint256 voting_receipt, uint256 otp) public{
        voting_receipt_book.push(voting_receipt * otp);
    }
    
}
