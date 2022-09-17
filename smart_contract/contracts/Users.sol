// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

import "./Types.sol";

contract Users 
{
    mapping(address => Types.UserDetails) internal users;
    mapping(address => Types.UserDetails[]) internal SuppliersList;

    event NewUser(string name, string email, Types.UserRole role);
    event LostUser(string name, string email, Types.UserRole role);

    function add(Types.UserDetails memory user) internal {
        require(user.id_ != address(0));
        require(!has(user.role, user.id_), "Same user with same role exists");
        users[user.id_] = user;
        emit NewUser(user.name, user.email, user.role);
    }

    function addparty(Types.UserDetails memory user, address myAccount) internal
    {
        require(myAccount != address(0));
        require(user.id_ != address(0));

        if (get(myAccount).role == Types.UserRole.Manufacturer && user.role == Types.UserRole.Supplier)
        {
            SuppliersList[myAccount].push(user);
            add(user);
        }
        else 
        {
            revert("Not valid operation");
        }
    }

    function getMyPartyList(address id_) internal view returns (Types.UserDetails[] memory usersList_)
    {
        require(id_ != address(0), "Id is empty");
        if (get(id_).role == Types.UserRole.Manufacturer) 
        {
            usersList_ = SuppliersList[id_];
        }
        else 
        {
            revert("Not valid operation");
        }
    }

    function getPartyDetails(address id_) internal view returns (Types.UserDetails memory)
    {
        require(id_ != address(0));
        require(get(id_).id_ != address(0));
        return get(id_);
    }

    function get(address account) internal view returns (Types.UserDetails memory)
    {
        require(account != address(0));
        return users[account];
    }

    function remove(Types.UserRole role, address account) internal 
    {
        require(account != address(0));
        require(has(role, account));
        string memory name_ = users[account].name;
        string memory email_ = users[account].email;
        delete users[account];
        emit LostUser(name_, email_, role);
    }

    function isPartyExists(address account) internal view returns (bool) 
    {
        bool existing_;
        if (account == address(0)) return existing_;
        if (users[account].id_ != address(0)) existing_ = true;
        return existing_;
    }

    function has(Types.UserRole role, address account) internal view returns (bool)
    {
        require(account != address(0));
        return (users[account].id_ != address(0) &&
            users[account].role == role);
    }

    modifier onlyManufacturer() {
        require(msg.sender != address(0), "Sender's address is Empty");
        require(users[msg.sender].id_ != address(0), "User's address is Empty");
        require( Types.UserRole(users[msg.sender].role) == Types.UserRole.Manufacturer, "Only manufacturer can add" );
        _;
    }
}
