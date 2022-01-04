// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DexDAO is ERC20, EIP712 {
    uint256 public constant MAX_SUPPLY = uint248(1e14 ether);

    // for DAO.
    uint256 public constant AMOUNT_DAO = MAX_SUPPLY / 100 * 25;
    address public constant ADDR_DAO = 0xF5f945FeD1165C6b3cE42429eeC9C9Ea7c48275d;

    //for operations.
    uint256 public constant AMOUNT_OPS = MAX_SUPPLY / 100 * 1;
    address public constant ADDR_OPS = 0xebB0C6be985dC86B3a956ebbf17aD93857EEd686;


    // for nft staking
    uint256 public constant AMOUNT_STAKING = MAX_SUPPLY / 100 * 14;
    address public constant ADDR_STAKING = 0x4A2bF201c7FA3503947eEFe006df7F0183533269;

    // for liquidity providers
    uint256 public constant AMOUNT_LP = MAX_SUPPLY / 100 * 10;
    address public constant ADDR_LP = 0x30B76abb0a2b425306FCd6a4E08F0C36eB0AB340;

    // for airdrop
    uint256 public constant AMOUNT_AIREDROP = MAX_SUPPLY - (AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP + AMOUNT_OPS);

    constructor(string memory _name, string memory _symbol, address _signer) ERC20(_name, _symbol) EIP712("DexDAO", "1") {
        _mint(ADDR_DAO, AMOUNT_DAO);
        _mint(ADDR_STAKING, AMOUNT_STAKING);
        _mint(ADDR_LP, AMOUNT_LP);
        _mint(ADDR_OPS, AMOUNT_OPS);
        _totalSupply = AMOUNT_DAO + AMOUNT_STAKING + AMOUNT_LP + AMOUNT_OPS;
        cSigner = _signer;
    }

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 amount)");

    address public immutable cSigner;

    function claim(uint256 amountV, bytes32 r, bytes32 s) external {
        uint256 amount = uint248(amountV);
        uint8 v = uint8(amountV >> 248);
        uint256 total = _totalSupply + amount;
        require(total <= MAX_SUPPLY, "DexDAO: Exceed max supply");
        require(minted(msg.sender) == 0, "DexDAO: Claimed");
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
            ECDSA.toTypedDataHash(_domainSeparatorV4(),
                keccak256(abi.encode(MINT_CALL_HASH_TYPE, msg.sender, amount))
        )));
        require(ecrecover(digest, v, r, s) == cSigner, "DexDAO: Invalid signer");
        _totalSupply = total;
        _mint(msg.sender, amount);
    }
}
