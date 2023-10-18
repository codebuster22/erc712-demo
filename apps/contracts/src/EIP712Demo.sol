// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {ECDSA, SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract EIP712Demo is EIP712Upgradeable {
    struct Wager {
        uint256 gameId;
        address captain;
        uint256 entryFee;
        bytes32 captainHash;
    }

    constructor() initializer {
        __EIP712_init("Wager", "0.1.0");
    }

    function getDomainSeparator() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getHash(
        Wager memory wager
    ) public view returns (bytes32) {
        bytes32 structHash =  getStructHash(wager);
        return _hashTypedDataV4(structHash);
    }

    function verifySignature(
        Wager memory wager,
        bytes memory signature,
        address signer
    ) public view returns (bool) {
        bytes32 structHash = getStructHash(
            wager
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        bytes32 ethSignedDigest = MessageHashUtils.toEthSignedMessageHash(
            digest
        );
        return
            SignatureChecker.isValidSignatureNow(
                signer,
                ethSignedDigest,
                signature
            );
    }

    function verifySignatureAndReturnSigner(
        Wager memory wager,
        bytes memory signature
    ) public view returns (address) {
        bytes32 structHash = getStructHash(
            wager
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        bytes32 ethSignedDigest = MessageHashUtils.toEthSignedMessageHash(
            digest
        );
        (address recovered, , ) = ECDSA.tryRecover(ethSignedDigest, signature);
        return recovered;
    }

    function verifySignatureTypedData(
        Wager memory wager,
        bytes memory signature,
        address signer
    ) public view returns (bool) {
        bytes32 structHash = getStructHash(
            wager
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    }

    function getStructHash(
        Wager memory wager
    ) public view returns (bytes32) {
        bytes32 STRUCT_TYPE_HASH = keccak256(
            "Wager(uint256 gameId,address captain,uint256 entryFee,bytes32 captainHash)"
        );
        return
            keccak256(
                abi.encode(
                    STRUCT_TYPE_HASH,
                    wager.gameId,
                    wager.captain,
                    wager.entryFee,
                    wager.captainHash
                )
            );
    }

    function verifySignatureAndReturnSignerTypedData(
        Wager memory wager,
        bytes memory signature
    ) public view returns (address) {
        bytes32 structHash = getStructHash(
            wager
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        (address recovered, , ) = ECDSA.tryRecover(digest, signature);
        return recovered;
    }
}
