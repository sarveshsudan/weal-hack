// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

import "./Types.sol";

contract Products {
    Types.Product[] internal products;
    mapping(string => Types.Product) internal product;
    mapping(address => string[]) internal userLinkedProducts;
    mapping(string => Types.ProductHistory) internal productHistory;

    event NewProduct(
        string name,
        string manufacturerName,
        string barcodeId
    );
    event ProductOwnershipTransfer(
        string name,
        string manufacturerName,
        string barcodeId,
        string buyerName,
        string buyerEmail
    );

    function getUserProducts() internal view returns (Types.Product[] memory) {
        string[] memory ids_ = userLinkedProducts[msg.sender];
        Types.Product[] memory products_ = new Types.Product[](ids_.length);
        for (uint256 i = 0; i < ids_.length; i++) {
            products_[i] = product[ids_[i]];
        }
        return products_;
    }

    function getSpecificProduct(string memory barcodeId_) internal view returns (Types.Product memory, Types.ProductHistory memory)
    {
        return (product[barcodeId_], productHistory[barcodeId_]);
    }

    function addAProduct(Types.Product memory product_, uint256 currentTime_)
        internal
        productNotExists(product_.barcodeId)
    {
        require(
            product_.manufacturer == msg.sender,
            "Only manufacturer can add"
        );
        products.push(product_);
        product[product_.barcodeId] = product_;
        productHistory[product_.barcodeId].manufacturer = Types.UserHistory({
            id_: msg.sender,
            date: currentTime_
        });
        userLinkedProducts[msg.sender].push(product_.barcodeId);
        emit NewProduct(
            product_.name,
            product_.manufacturerName,
            product_.barcodeId
        );
    }

    function sell(
        address partyId_,
        string memory barcodeId_,
        Types.UserDetails memory party_,
        uint256 currentTime_
    ) internal productExists(barcodeId_) {
        Types.Product memory product_ = product[barcodeId_];

        // Updating product history
        Types.UserHistory memory userHistory_ = Types.UserHistory({
            id_: party_.id_,
            date: currentTime_
        });
        if (Types.UserRole(party_.role) == Types.UserRole.Supplier) {
            productHistory[barcodeId_].supplier = userHistory_;
        } else if (Types.UserRole(party_.role) == Types.UserRole.Vendor) {
            productHistory[barcodeId_].vendor = userHistory_;
        } else if (Types.UserRole(party_.role) == Types.UserRole.Customer) {
            productHistory[barcodeId_].customers.push(userHistory_);
        } else {
            // Not in the assumption scope
            revert("Not valid operation");
        }
        transferOwnership(msg.sender, partyId_, barcodeId_); // To transfer ownership from seller to buyer

        // Emiting event
        emit ProductOwnershipTransfer(
            product_.name,
            product_.manufacturerName,
            product_.barcodeId,
            party_.name,
            party_.email
        );
    }

    // Modifiers
    modifier productExists(string memory id_) {
        require(!compareStrings(product[id_].barcodeId, ""));
        _;
    }

    modifier productNotExists(string memory id_) {
        require(compareStrings(product[id_].barcodeId, ""));
        _;
    }

    // Internal functions

    function transferOwnership(
        address sellerId_,
        address buyerId_,
        string memory productId_
    ) internal {
        userLinkedProducts[buyerId_].push(productId_);
        string[] memory sellerProducts_ = userLinkedProducts[sellerId_];
        uint256 matchIndex_ = (sellerProducts_.length + 1);
        for (uint256 i = 0; i < sellerProducts_.length; i++) {
            if (compareStrings(sellerProducts_[i], productId_)) {
                matchIndex_ = i;
                break;
            }
        }
        assert(matchIndex_ < sellerProducts_.length); // Match found
        if (sellerProducts_.length == 1) {
            delete userLinkedProducts[sellerId_];
        } else {
            userLinkedProducts[sellerId_][matchIndex_] = userLinkedProducts[
                sellerId_
            ][sellerProducts_.length - 1];
            delete userLinkedProducts[sellerId_][sellerProducts_.length - 1];
            userLinkedProducts[sellerId_].pop();
        }
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
