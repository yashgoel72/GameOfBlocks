// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.7.0;

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract MetaCoin {
	mapping (address => uint256) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		balances[tx.origin] = 100000;
	}

	function sendCoin(address receiver, uint256 amount, address sender) public returns(bool sufficient) {
		if (balances[sender] < amount) return false;
		balances[sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(sender, receiver, amount);
		return true;
	}


	function getBalance(address addr) public view returns(uint256) {
		return balances[addr];
	}
}

// Try not to edit the contract definition above

contract Loan is MetaCoin {
// You can edit this contract as much as you want. A template is provided here and you can change the function names and implement anything else you want, but the basic tasks mentioned here should be accomplished.
    mapping (address => uint256) private loans;
     
    event Request(address indexed _from, uint256 P, uint R, uint T, uint256 amt);
    
    address private Owner;

    
    modifier isOwner() {
        // Implement a modifier to allow only the owner of the contract to use specific functions
        require(Owner == msg.sender);
        _;
    }
    
    constructor() public {
       Owner = tx.origin;
    }
    
    // Fill up the following function definitions and also try to justify why some functions are pure and some are view and some are none, in your README.md
    
    function getCompoundInterest(uint256 principle, uint rate, uint time) public pure returns(uint256) {
    	
    	uint256 R = rate;
    	uint256 totalInterest = 0;
    	for(uint i = 1;i<=time;i++)
    	{
    	    uint256 interest = principle * R/100;
    	    totalInterest += interest;
    	    principle += interest;
    	}
    	return totalInterest;
    }
    
    function reqLoan(uint256 principle, uint rate, uint time) public payable returns(bool correct) {
        uint256 toPay = getCompoundInterest(principle, rate, time);
        loans[msg.sender] += toPay;
        emit Request(msg.sender, principle , rate , time , loans[msg.sender]) ;
        return true;
    }
    
    function getOwnerBalance() public view returns(uint256) {
				// use the getBalance function of MetaCoin contract to view the Balance of the contract Owner.
				// hint: how do you access the functions / variables of the parent class in your favorite programming language? It is similar to that in solidity as well!
		
        return (getBalance(Owner));
        
    }
    
    function viewDues(address payable ad) public view isOwner returns(uint256)
    {
        return loans[ad];
    }
    
    function settleDues(address payable ad) public isOwner
    {
    require( getOwnerBalance() >= loans[ad] , "Not Enough Balance to settle Dues");
       require(loans[ad] !=0 , "Dues Already Settled");
       bool b = sendCoin( ad , loans[ad] , Owner);
        if (b)
        loans[ad]=0;
    }
		function addLoansMap(address payable ad , uint256 amount) public payable
		{
		    loans [ad] += amount;
		    balances[ad] +=0;
		}
    
    // implement viewDues and settleDues which allow *ONLY* the owner to *view* and *settle* his loans respectively. They take in the address of a creditor as arguments. viewDues returns a uint256 corresponding to the due amount, and does not modify any state variables. settleDues returns a bool, true if the dues were settled and false otherwise. Remember to set the the pending loan to 0 after settling the dues.
    // use sendCoin function of MetaCoin contract to send the coins required for settling the dues.
    
}
