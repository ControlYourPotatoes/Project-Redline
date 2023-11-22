// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract FarmHurricaneInsurance is ChainlinkClient, KeeperCompatibleInterface {
    using Chainlink for Chainlink.Request;

    // Define the structure for a farm's insurance policy
    struct Policy {
        uint256 policyId;
        address payable beneficiary;
        uint256 insuredAmount;
        bool isInsured;
        uint256 premium;
    }

    // Static coordinates for the insured farm
    struct Coordinate {
        string lat;
        string lng;
    }
    Coordinate public insuredFarmLocation;

    // Keep track of the latest weather data
    struct WeatherData {
        uint256 requestId;
        uint256 hurricaneCategory;
    }
    WeatherData public latestWeatherData;

    // Events
    event PolicyCreated(uint256 policyId, address beneficiary);
    event PolicyClaimed(uint256 policyId, uint256 payoutAmount);
    event WeatherDataUpdated(uint256 hurricaneCategory);

    // Mapping of policy IDs to policies
    mapping(uint256 => Policy) public policies;
    uint256 public nextPolicyId;

    // Chainlink specifics
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    // Constructor
    constructor(address _oracle, bytes32 _jobId, uint256 _fee, string memory _lat, string memory _lng) {
        setChainlinkToken(LINK_TOKEN_ADDRESS);
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        insuredFarmLocation = Coordinate(_lat, _lng);
        nextPolicyId = 1;
    }

    // Function to create a new insurance policy
    function createPolicy(address payable beneficiary, uint256 insuredAmount, uint256 premium) public {
        uint256 policyId = nextPolicyId++;
        policies[policyId] = Policy(policyId, beneficiary, insuredAmount, true, premium);
        emit PolicyCreated(policyId, beneficiary);
    }

    // Function to request weather data from the oracle
    function requestWeatherData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // Set the path to find the desired data in the API response
        request.add("lat", insuredFarmLocation.lat);
        request.add("lng", insuredFarmLocation.lng);
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // Callback function used by Chainlink's oracle service
    function fulfill(bytes32 _requestId, uint256 _hurricaneCategory) public recordChainlinkFulfillment(_requestId) {
        latestWeatherData = WeatherData(_requestId, _hurricaneCategory);
        emit WeatherDataUpdated(_hurricaneCategory);
        // Check if the hurricane category meets the criteria for a claim
        if (_hurricaneCategory >= 3) { // Example threshold
            processClaims(_hurricaneCategory);
        }
    }

    // Function to process claims based on updated weather data
    function processClaims(uint256 _hurricaneCategory) internal {
        // Iterate through all policies
        for (uint256 i = 1; i < nextPolicyId; i++) {
            // Check if the policy is active
            if (policies[i].isInsured) {
                // Check if the policy is eligible for a claim
                if (_hurricaneCategory >= 3) { // Example threshold
                    // Send the payout to the beneficiary
                    policies[i].beneficiary.transfer(policies[i].insuredAmount);
                    // Mark the policy as inactive
                    policies[i].isInsured = false;
                    emit PolicyClaimed(i, policies[i].insuredAmount);
                }
            }
        }
    }
    