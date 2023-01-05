// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;

contract CrowdfundingCampaign {
    // The address that will receive the funds
    address payable recipient;

    // The minimum amount of funds needed to succeed
    uint256 goal;

    // The amount of funds that have been pledged so far
    uint256 pledged;

    // The amount of funds that have been claimed so far
    uint256 claimed;

    // The deadline for pledging funds
    uint256 deadline;

    // The state of the campaign
    enum State { Active, Success, Failed }
    State public state;

    // Events
    event GoalReached();
    event FundClaimed(uint256 amount);

    // Constructor
    constructor(address payable _recipient, uint256 _goal, uint256 _deadline) public {
        recipient = _recipient;
        goal = _goal;
        deadline = _deadline;
    }

    // Fallback function to handle incoming funds
    function () external payable {
        require(state == State.Active, "The campaign is not active");
        require(now <= deadline, "The deadline has passed");

        pledged += msg.value;
        if (pledged >= goal) {
            state = State.Success;
            GoalReached();
        }
    }

    // Function to claim funds from the campaign
    function claim() public {
        require(state == State.Success, "The campaign was not successful");
        require(claimed < pledged, "All funds have already been claimed");

        uint256 amount = msg.sender.balance;
        msg.sender.transfer(amount);
        claimed += amount;

        FundClaimed(amount);
    }
}