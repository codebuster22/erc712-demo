import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { EIP712Demo } from "../typechain-types";
import {ethers} from "hardhat";
import { expect } from "chai";
import { Bytes, BytesLike, arrayify, hexlify, parseUnits } from "ethers/lib/utils";

describe("EIP712Demo", () => {
    let signer: SignerWithAddress;
    let demo: EIP712Demo;
    const gameId = 1;
    let captain: SignerWithAddress;
    let entryFee = parseUnits("1", "ether");
    let hashSignature: BytesLike;
    let typedDataSignature: BytesLike;
    let TYPED_DATA;
    let wager;
    beforeEach("> generate signature", async () => {
        const demoFactory = await ethers.getContractFactory("EIP712Demo");
        demo = await demoFactory.deploy() as EIP712Demo;

        ([signer, captain] = await ethers.getSigners());




        // generate typed data signature
        const cid = (await signer.provider!!.getNetwork()).chainId;
        const Wager = [
                { name: 'gameId', type: 'uint256' },
                { name: 'captain', type: 'address' },
                { name: 'entryFee', type: 'uint256' },
                { name: 'captainHash', type: 'bytes32'}
            ];
        TYPED_DATA = {
            types: {
                Wager
            },
            domain: {
                verifyingContract: demo.address,
                version: "0.1.0",
                name: "Wager",
                chainId: cid
            },
            primaryType: "Wager",
            message: {
                gameId: gameId,
                captain: captain.address,
                entryFee: entryFee,
                captainHash: ethers.utils.randomBytes(32)
            }
        };
        wager = TYPED_DATA.message;

        const hashToSign = await demo.getHash(wager);

        // without arrayify() the hashToSign will be considered a string.
        // i.e. we need to convert hashToSign to a bytes array
        hashSignature = await signer.signMessage(arrayify(hashToSign));
        typedDataSignature = await signer._signTypedData(TYPED_DATA.domain, TYPED_DATA.types, TYPED_DATA.message);
    });

    it("signature is valid", async () => {
        const isValid = await demo.verifySignature(wager, hashSignature, signer.address);
        expect(isValid).to.be.true;
    })

    it("signature is valid and returns address", async () => {
        const recovered = await demo.verifySignatureAndReturnSigner(wager, hashSignature);
        expect(recovered).to.equal(signer.address);
    })

    it("TypedData: signature is valid", async () => {
        const isValid = await demo.verifySignatureTypedData(wager, typedDataSignature, signer.address);
        expect(isValid).to.be.true;
    })

    it("TypedData: signature is valid and returns address", async () => {
        const recovered = await demo.verifySignatureAndReturnSignerTypedData(wager, typedDataSignature);
        expect(recovered).to.equal(signer.address);
    })
})