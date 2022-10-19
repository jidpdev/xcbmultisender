// SPDX-License-Identifier: MIT

// Crypto Birds XCB Multisender 1.4
// This smart contract is created by the Community and is not affiliated with Crypto Birds Platform.
// Please visit cryptobirds.com if you are looking for official information.

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Multisender {

    address public owner;
    IERC20Metadata public tokenContract;
    uint256 public walletMaxAllowed;
    address[] internal walletAccounts;
	uint256[] internal walletAmounts;
	uint256 public totalAmountToSend;
    uint256 public totalWalletsToSend;
	
	event Sent(address _from, address _to, uint256 _amount);
	
    constructor (
                IERC20Metadata _tokenContract, 
                uint256 _walletMaxAllowed
        ) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        walletMaxAllowed = _walletMaxAllowed;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Error. Caller is not the owner.");
        _;
    }

    // ----------------------
    // Token info

    function getTokenName() external view returns (string memory) {
        return tokenContract.name(); 
    }

    function getTokenSymbol() external view returns (string memory) {
        return tokenContract.symbol(); 
    }

    function getTokenBalance() external view returns (uint256) {
        return tokenContract.balanceOf(address(this)); 
    }

    // ----------------------
    // Contract

    function setMultisender(address[] memory _accounts, uint256[] memory _amounts) external onlyOwner {
        walletAccounts = _accounts;
        totalWalletsToSend = _accounts.length;
        walletAmounts = _amounts;
		totalAmountToSend = 0;
        for (uint256 _index = 0; _index < _accounts.length; _index++) {
			totalAmountToSend += _amounts[_index];
		}
    } 	
	
    function updateContractSettings(IERC20Metadata _tokenContract, uint256 _walletMaxAllowed) external onlyOwner {
		tokenContract = _tokenContract;
        walletMaxAllowed = _walletMaxAllowed;
    } 	

    function withdrawContract(uint256 _tokenAmount) external onlyOwner {
        tokenContract.transfer(address(msg.sender), _tokenAmount);
    }

	// ----------------------
	// Go!

    function goMultisender() external onlyOwner {
		    processDelivery(tokenContract, walletAccounts, walletAmounts);
    } 	

    function processDelivery(IERC20Metadata _token, address[] memory _accounts, uint256[] memory _amounts) internal {
        require(_accounts.length == _amounts.length, "Error. The accounts size and amounts size not equals.");
        require(_accounts.length <= walletMaxAllowed, "Error. The number of accounts exceeds the maximum limit.");
		require(totalAmountToSend <= _token.balanceOf(address(this)), "Error. Insufficient balance.");
        for (uint256 _index = 0; _index < _accounts.length; _index++) {
            _token.transfer( _accounts[_index], _amounts[_index]);
			emit Sent(address(this), _accounts[_index], _amounts[_index]);
		}
    }	

}	
