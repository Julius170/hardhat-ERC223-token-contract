// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// interface IERC223 {
//     function balanceOf(address who) external view returns (uint256);

//     function totalSupply() external view returns (uint256);

//     function transfer(
//         address to,
//         uint256 value,
//         bytes calldata data
//     ) external returns (bool);

//     event Transfer(
//         address indexed from,
//         address indexed to,
//         uint256 value,
//         bytes indexed data
//     );
// }

// interface IERC223Recipient {
//     function tokenFallback(
//         address from,
//         uint256 value,
//         bytes calldata data
//     ) external;
// }

// contract MyToken is IERC223 {
//     string private _name;
//     string private _symbol;
//     uint8 private _decimals;
//     uint256 private _totalSupply;
//     mapping(address => uint256) private _balances;

//     constructor() // string memory name_,
//     // string memory symbol_,
//     // uint8 decimals_,
//     // uint256 totalSupply_
//     {
//         _name = "PHENZ";
//         _symbol = "PHZ";
//         _decimals = 20;
//         _totalSupply = 250;
//         _balances[msg.sender] = _totalSupply;
//     }

//     function name() public view returns (string memory) {
//         return _name;
//     }

//     function symbol() public view returns (string memory) {
//         return _symbol;
//     }

//     function decimals() public view returns (uint8) {
//         return _decimals;
//     }

//     function totalSupply() public view override returns (uint256) {
//         return _totalSupply;
//     }

//     function balanceOf(address who) public view override returns (uint256) {
//         return _balances[who];
//     }

//     function transfer(
//         address to,
//         uint256 value,
//         bytes calldata data
//     ) public override returns (bool) {
//         require(to != address(0), "ERC223: transfer to the zero address");

//         uint256 senderBalance = _balances[msg.sender];
//         require(
//             senderBalance >= value,
//             "ERC223: transfer amount exceeds balance"
//         );

//         _balances[msg.sender] = senderBalance - value;
//         _balances[to] += value;

//         if (isContract(to)) {
//             IERC223Recipient receiver = IERC223Recipient(to);
//             receiver.tokenFallback(msg.sender, value, data);
//         }

//         emit Transfer(msg.sender, to, value, data);
//         return true;
//     }

//     function isContract(address _addr) private view returns (bool) {
//         uint256 codeLength;
//         assembly {
//             codeLength := extcodesize(_addr)
//         }
//         return codeLength > 0;
//     }
// }

// SPDX License-Identifier: MIT
/**
 * @title Contract that will work with ERC223 tokens.
 */
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC223 standard token as defined in the EIP.
 */
abstract contract IERC223 {
    function name() public view virtual returns (string memory);

    function symbol() public view virtual returns (string memory);

    function standard() public view virtual returns (string memory);

    function decimals() public view virtual returns (uint8);

    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address who) public view virtual returns (uint);

    function transfer(
        address to,
        uint value
    ) public virtual returns (bool success);

    function transfer(
        address to,
        uint value,
        bytes calldata data
    ) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);

    event TransferData(bytes data);
}

abstract contract IERC223Recipient {
    struct ERC223TransferInfo {
        address token_contract;
        address sender;
        uint256 value;
        bytes data;
    }

    ERC223TransferInfo private tkn;

    function tokenReceived(
        address _from,
        uint _value,
        bytes memory _data
    ) public virtual {
        tkn.token_contract = msg.sender;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function toPayable(
        address account
    ) internal pure returns (address payable) {
        return payable(account);
    }
}

/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract MyToken is IERC223 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) public balances; // List of user balances.

    constructor() {
        _name = "PHENZ";
        _symbol = "PHZ";
        _decimals = 10;
        _totalSupply = 100000000000000000000;
    }

    function standard() public pure override returns (string memory) {
        return "erc223";
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint _value,
        bytes calldata _data
    ) public override returns (bool success) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if (Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_data);
        return true;
    }

    function transfer(
        address _to,
        uint _value
    ) public override returns (bool success) {
        bytes memory _empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if (Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _empty);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_empty);
        return true;
    }
}
