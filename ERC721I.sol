// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/* ERC721I - ERC721I (ERC721 0xInuarashi Edition) - Gas Optimized
    Open Source: with the efforts of the [0x Collective] <3 */

contract ERC721I {

    string public name; string public symbol;
    string internal baseTokenURI; string internal baseTokenURI_EXT;
    constructor(string memory name_, string memory symbol_) {
        name = name_; symbol = symbol_; 
    }

    uint256 public totalSupply; 
    mapping(uint256 => address) public ownerOf; 
    mapping(address => uint256) public balanceOf; 

    mapping(uint256 => address) public getApproved; 
    mapping(address => mapping(address => bool)) public isApprovedForAll; 

    // Events:

    event Transfer(address indexed from, address indexed to, 
    uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, 
    uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, 
    bool approved);

    // internal write functions:

    // Mint function:
    function _mint(address to_, uint256 tokenId_) internal virtual {
        require(to_ != address(0x0), 
            "ERC721I: _mint() Mint to Zero Address");
        require(ownerOf[tokenId_] == address(0x0), 
            "ERC721I: _mint() Token to Mint Already Exists!");

        balanceOf[to_]++;
        ownerOf[tokenId_] = to_;

        emit Transfer(address(0x0), to_, tokenId_);
    }

    // Transfer function:

    function _transfer(address from_, address to_, uint256 tokenId_) internal virtual {
        require(from_ == ownerOf[tokenId_], 
            "ERC721I: _transfer() Transfer Not Owner of Token!");
        require(to_ != address(0x0), 
            "ERC721I: _transfer() Transfer to Zero Address!");

        // Checks if there is an approved address | Clears it if there is:
        if (getApproved[tokenId_] != address(0x0)) { 
            _approve(address(0x0), tokenId_); 
        } 

        ownerOf[tokenId_] = to_; 
        balanceOf[from_]--;
        balanceOf[to_]++;

        emit Transfer(from_, to_, tokenId_);
    }

    // Approve functions:

    function _approve(address to_, uint256 tokenId_) internal virtual {
        if (getApproved[tokenId_] != to_) {
            getApproved[tokenId_] = to_;
            emit Approval(ownerOf[tokenId_], to_, tokenId_);
        }
    }

    function _setApprovalForAll(address owner_, address operator_, bool approved_)
    internal virtual {
        require(owner_ != operator_, 
            "ERC721I: _setApprovalForAll() Owner must not be the Operator!");
        isApprovedForAll[owner_][operator_] = approved_;
        emit ApprovalForAll(owner_, operator_, approved_);
    }

    // Token URI:

    function _setBaseTokenURI(string memory uri_) internal virtual {
        baseTokenURI = uri_;
    }

    function _setBaseTokenURI_EXT(string memory ext_) internal virtual {
        baseTokenURI_EXT = ext_;
    }

    // internal view functions | Embedded libraries:

    function _toString(uint256 value_) internal pure returns (string memory) {
        if (value_ == 0) { return "0"; }
        uint256 _iterate = value_; uint256 _digits;
        while (_iterate != 0) { _digits++; _iterate /= 10; } // Get digits in 'value_'
        bytes memory _buffer = new bytes(_digits);
        while (value_ != 0) { _digits--; _buffer[_digits] = bytes1(uint8(
            48 + uint256(value_ % 10 ))); value_ /= 10; } // Create bytes of 'value_'
        return string(_buffer); // Return string converted bytes of 'value_'
    }

    // Functional views:

    function _isApprovedOrOwner(address spender_, uint256 tokenId_) internal 
    view virtual returns (bool) {
        require(ownerOf[tokenId_] != address(0x0), 
            "ERC721I: _isApprovedOrOwner() Owner is Zero Address!");
        address _owner = ownerOf[tokenId_];
        return (spender_ == _owner 
            || spender_ == getApproved[tokenId_] 
            || isApprovedForAll[_owner][spender_]);
    }

    function _exists(uint256 tokenId_) internal view virtual returns (bool) {
        return ownerOf[tokenId_] != address(0x0);
    }

    // public write functions:

    function approve(address to_, uint256 tokenId_) public virtual {
        address _owner = ownerOf[tokenId_];
        require(to_ != _owner, 
            "ERC721I: approve() Cannot approve yourself!");
        require(msg.sender == _owner || isApprovedForAll[_owner][msg.sender],
            "ERC721I: Caller not owner or Approved!");
        _approve(to_, tokenId_);
    }

    function setApprovalForAll(address operator_, bool approved_) public virtual {
        _setApprovalForAll(msg.sender, operator_, approved_);
    }

    function transferFrom(address from_, address to_, uint256 tokenId_) 
    public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId_), 
            "ERC721I: transferFrom() _isApprovedOrOwner = false!");
        _transfer(from_, to_, tokenId_);
    }

    function safeTransferFrom(address from_, address to_, uint256 tokenId_, 
    bytes memory data_) public virtual {
        transferFrom(from_, to_, tokenId_);
        if (to_.code.length != 0) {
            (, bytes memory _returned) = to_.staticcall(abi.encodeWithSelector(
                0x150b7a02, msg.sender, from_, tokenId_, data_));
            bytes4 _selector = abi.decode(_returned, (bytes4));
            require(_selector == 0x150b7a02, 
                "ERC721I: safeTransferFrom() to_ not ERC721Receivable!");
        }
    }

    function safeTransferFrom(address from_, address to_, uint256 tokenId_) 
    public virtual {
        safeTransferFrom(from_, to_, tokenId_, "");
    }

    // 0xInuarashi's Custom Functions:

    function multiTransferFrom(address from_, address to_, 
    uint256[] memory tokenIds_) public virtual {
        for (uint256 i = 0; i < tokenIds_.length; i++) {
            transferFrom(from_, to_, tokenIds_[i]);
        }
    }

    function multiSafeTransferFrom(address from_, address to_, 
    uint256[] memory tokenIds_, bytes memory data_) public virtual {
        for (uint256 i = 0; i < tokenIds_.length; i++) {
            safeTransferFrom(from_, to_, tokenIds_[i], data_);
        }
    }

    // OpenZeppelin standard requires:

    function supportsInterface(bytes4 interfaceId_) public pure returns (bool) {
        return (interfaceId_ == 0x80ac58cd || interfaceId_ == 0x5b5e139f);
    }

    function tokenURI(uint256 tokenId_) public view virtual returns (string memory) {
        require(ownerOf[tokenId_] != address(0x0), 
            "ERC721I: tokenURI() Token does not exist!");
        return string(abi.encodePacked(
            baseTokenURI, _toString(tokenId_), baseTokenURI_EXT));
    }

    // Never use these functions, for they are expensive and for view only.

    function walletOfOwner(address address_) public virtual view 
    returns (uint256[] memory) {
        uint256 _balance = balanceOf[address_];
        uint256[] memory _tokens = new uint256[] (_balance);
        uint256 _index;
        uint256 _loopThrough = totalSupply;
        for (uint256 i = 0; i < _loopThrough; i++) {
            if (ownerOf[i] == address(0x0) && _tokens[_balance - 1] == 0) {
                _loopThrough++; 
            }
            if (ownerOf[i] == address_) { 
                _tokens[_index] = i; _index++; 
            }
        }
        return _tokens;
    }

    // Unsure of when this will be needed- but it conforms to 'ERC721Enumerable'.

    function tokenOfOwnerByIndex(address address_, uint256 index_) public 
    virtual view returns (uint256) {
        uint256[] memory _wallet = walletOfOwner(address_);
        return _wallet[index_];
    }
}
