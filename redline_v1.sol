pragma solidity ^0.8.0;

contract HurricaneInsurance {
    struct Location {
        uint256 latitude;
        uint256 longitude;
    }

    Location public userLocation;
    Location public hurricaneLocation;
    uint256 constant THRESHOLD_DISTANCE = 50; // in km

    // Function for user to set their location
    function setUserLocation(uint256 _latitude, uint256 _longitude) public {
        userLocation = Location(_latitude, _longitude);
    }

    // Oracle updates hurricane location
    function updateHurricaneLocation(uint256 _latitude, uint256 _longitude) external {
        // This function should be restricted to be called only by the oracle
        hurricaneLocation = Location(_latitude, _longitude);
        if (isWithinThreshold(userLocation, hurricaneLocation)) {
            // Trigger contract closing logic
        }
    }

    function isWithinThreshold(Location memory loc1, Location memory loc2) private pure returns (bool) {
        // Implement distance calculation and compare with THRESHOLD_DISTANCE
        // Return true if within 50km
    }

    // Additional functions as needed...
}
