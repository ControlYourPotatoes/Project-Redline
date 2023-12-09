// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ABDKMathQuad.sol"; // Import the ABDKMathQuad library

contract IndividualInsuranceContract {
    struct Location {
        uint256 latitude;
        uint256 longitude;
    }

    Location public insuredLocation;
    address public insuredParty;
    bool public contractFulfilled;
    address private oracleAddress;

    // Events
    event InsuranceUpdated(bool fulfilled);
    event HurricaneLocationUpdated(uint256 latitude, uint256 longitude);

    // Constructor
    constructor(uint256 _latitude, uint256 _longitude, address _insuredParty, address _oracleAddress) {
        insuredLocation = Location(_latitude, _longitude);
        insuredParty = _insuredParty;
        contractFulfilled = false;
        oracleAddress = _oracleAddress;
    }

    // Function for user to set their location// Function to enable or disable mock mode (onlyOwner modifier is recommended)
    function setMockMode(bool _isEnabled) public {
        bool isMockModeEnabled = _isEnabled;
    }
    // Modified updateHurricaneLocation function to accept mock data if mock mode is enabled
    function updateHurricaneLocation(uint256 _latitude, uint256 _longitude) external {
        require(msg.sender == oracleAddress || isMockModeEnabled, "Unauthorized");

        if (isWithinThreshold(insuredLocation, Location(_latitude, _longitude))) {
            contractFulfilled = true;
            emit InsuranceUpdated(true);
        }
        emit HurricaneLocationUpdated(_latitude, _longitude);
    }

    // Check if the hurricane is within the specified threshold distance
    // Function using ABDKMathQuad for trigonometric calculations
    function isWithinThreshold(Location memory loc1, Location memory loc2) private pure returns (bool) {
        bytes16 R = ABDKMathQuad.fromUInt(6371); // Earth's radius in kilometers
        bytes16 lat1 = ABDKMathQuad.fromUInt(loc1.latitude);
        bytes16 lon1 = ABDKMathQuad.fromUInt(loc1.longitude);
        bytes16 lat2 = ABDKMathQuad.fromUInt(loc2.latitude);
        bytes16 lon2 = ABDKMathQuad.fromUInt(loc2.longitude);
        
        bytes16 dLat = ABDKMathQuad.div(ABDKMathQuad.sub(lat2, lat1), ABDKMathQuad.fromUInt(2));
        bytes16 dLon = ABDKMathQuad.div(ABDKMathQuad.sub(lon2, lon1), ABDKMathQuad.fromUInt(2));
        
        bytes16 a = ABDKMathQuad.add(
            ABDKMathQuad.mul(ABDKMathQuad.sin(dLat), ABDKMathQuad.sin(dLat)),
            ABDKMathQuad.mul(
                ABDKMathQuad.mul(ABDKMathQuad.cos(lat1), ABDKMathQuad.cos(lat2)),
                ABDKMathQuad.mul(ABDKMathQuad.sin(dLon), ABDKMathQuad.sin(dLon))
            )
        );

        bytes16 c = ABDKMathQuad.mul(ABDKMathQuad.fromUInt(2), ABDKMathQuad.atan2(ABDKMathQuad.sqrt(a), ABDKMathQuad.sqrt(ABDKMathQuad.sub(ABDKMathQuad.fromUInt(1), a))));

        bytes16 distance = ABDKMathQuad.mul(R, c); // Distance in kilometers

        return ABDKMathQuad.toUInt(distance) <= 50; // Returns true if the distance is less than or equal to 50 kilometers
    }

    // Additional functions...
}

contract InsuranceFactory {
    IndividualInsuranceContract[] public insuranceContracts;
    address private oracleAddress;

    // Event
    event InsurancePolicyCreated(address contractAddress, uint256 latitude, uint256 longitude, address insuredParty);

    // Constructor
    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
    }

    // Create a new insurance policy
    function createInsurance(uint256 _latitude, uint256 _longitude) public {
        IndividualInsuranceContract newContract = new IndividualInsuranceContract(_latitude, _longitude, msg.sender, oracleAddress);
        insuranceContracts.push(newContract);
        emit InsurancePolicyCreated(address(newContract), _latitude, _longitude, msg.sender); // Emit event
    }

    // Additional factory-related functions...
}
