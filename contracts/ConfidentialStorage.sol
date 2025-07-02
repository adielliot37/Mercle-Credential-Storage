// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract CredentialManager is AccessControl {
    // Role definitions
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    struct Credential {
        uint256 expiry; // timestamp when credential expires
        bool active; // revocation flag; false if revoked
        bytes32 dataHash; // off-chain metadata hash
    }

    mapping(address => Credential) private credentials;

    event CredentialIssued(
        address indexed user,
        uint256 expiry,
        bytes32 dataHash
    );

    event CredentialRenewed(address indexed user, uint256 newExpiry);
    event CredentialRevoked(address indexed user);

    constructor(address admin) {
        // Grant admin roles using _grantRole instead of deprecated _setupRole
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ISSUER_ROLE, admin);
    }

    modifier onlyIssuer() {
        require(
            hasRole(ISSUER_ROLE, msg.sender),
            "Caller is not an authorized issuer"
        );
        _;
    }

    function issueCredential(
        address user,
        uint256 validityPeriod,
        bytes32 dataHash
    ) external onlyIssuer {
        uint256 expiry = block.timestamp + validityPeriod;
        credentials[user] = Credential({
            expiry: expiry,
            active: true,
            dataHash: dataHash
        });
        emit CredentialIssued(user, expiry, dataHash);
    }

    function renewCredential(address user, uint256 additionalPeriod)
        external
        onlyIssuer
    {
        Credential storage cred = credentials[user];
        require(cred.active, "Credential has been revoked");
        cred.expiry = block.timestamp + additionalPeriod;
        emit CredentialRenewed(user, cred.expiry);
    }

    function revokeCredential(address user) external onlyIssuer {
        Credential storage cred = credentials[user];
        require(cred.active, "Credential already revoked");
        cred.active = false;
        emit CredentialRevoked(user);
    }

    function isValid(address user) external view returns (bool) {
        Credential storage cred = credentials[user];
        return cred.active && block.timestamp <= cred.expiry;
    }

    function getCredential(address user)
        external
        view
        returns (
            uint256 expiry,
            bool activeStatus,
            bytes32 metadataHash
        )
    {
        Credential storage cred = credentials[user];
        return (cred.expiry, cred.active, cred.dataHash);
    }
}
