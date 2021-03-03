// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "./openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol";
import "./openzeppelin-contracts/contracts/utils/Context.sol";
import "./openzeppelin-contracts/contracts/utils/Counters.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract tokew_contract_0_1 is Context, AccessControlEnumerable, ERC721Enumerable, ERC721Burnable, ERC721Pausable {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    //Tracking for tokenIDs
    Counters.Counter private _tokenIds;

    // mapping Token is transferable
    mapping(uint256 => bool) private _tokenIsTransferables;

    // mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    string private _baseTokenURI;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        // _setupRole(MINTER_ROLE, _msgSender());
        // _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }


    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function admPause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function admUnpause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


     function admMint(address player, string memory _tokenURI) public returns (uint256)
    {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        admSetTokenIsTransferable(newItemId, true);

        return newItemId;
    }
    

     
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function admTokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory baseURI = _baseURI();

        return string(abi.encodePacked(baseURI, _tokenURI));

    }

    function admSetTokenIsTransferable(uint256 tokenId, bool _tokenIsTransferable) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenIsTransferables[tokenId] = _tokenIsTransferable;
    }

    function tokenIsTransferable(uint256 tokenId) public view returns (bool){
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _tokenIsTransferables[tokenId];

    }

    //override transferFrom function
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(tokenIsTransferable(tokenId), "This token token is not transferable at this time");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    //override safeTransferFrom
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(tokenIsTransferable(tokenId), "This token is not transferable at this time");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _safeTransfer(from, to, tokenId, _data);
    }

    function admTransferFrom(address from, address to, uint256 tokenId) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have admin role to use this function");

        _transfer(from, to, tokenId);
    }

    function admSafeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have admin role to use this function");

        _safeTransfer(from, to, tokenId, _data);
    }

    //override burn function
    function admBurn(uint256 tokenId) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have admin role to use this function");

        _burn(tokenId);
    }



}
