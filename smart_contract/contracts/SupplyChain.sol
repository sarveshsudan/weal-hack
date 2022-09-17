// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

import "./Products.sol";
import "./Users.sol";

contract SupplyChain is Users, Products {
    constructor(string memory name_, string memory email_) {
        Types.UserDetails memory mn_ = Types.UserDetails({
            role: Types.UserRole.Manufacturer,
            id_: msg.sender,
            name: name_,
            email: email_
        });
        add(mn_);
    }

    function getAllProducts() public view returns (Types.Product[] memory) {
        return products;
    }

    function getMyProducts() public view returns (Types.Product[] memory) {
        return getUserProducts();
    }

    function getSingleProduct(string memory barcodeId_) public view returns (Types.Product memory, Types.ProductHistory memory)
    {
        return getSpecificProduct(barcodeId_);
    }

    function addProduct(Types.Product memory product_, uint256 currentTime_) public onlyManufacturer
    {
        addAProduct(product_, currentTime_);
    }

    function sellProduct( address partyId_, string memory barcodeId_, uint256 currentTime_) public 
    {
        require(isPartyExists(partyId_), "Party not found");
        Types.UserDetails memory party_ = users[partyId_];
        sell(partyId_, barcodeId_, party_, currentTime_);
    }

    function addParty(Types.UserDetails memory user_) public {
        addparty(user_, msg.sender);
    }

    function getUserDetails(address id_) public view returns (Types.UserDetails memory)
    {
        return getPartyDetails(id_);
    }

    function getMyDetails() public view returns (Types.UserDetails memory) {
        return getPartyDetails(msg.sender);
    }

    function getMyUsersList() public view returns (Types.UserDetails[] memory usersList_)
    {
        return getMyPartyList(msg.sender);
    }
}
