// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

library Types {
    //creating users in website
    enum UserRole {
        Manufacturer, // 0
        Supplier, // 1
        Vendor, // 2
        Customer // 3
    }

    //this is for login portal first page
    struct UserDetails {
        UserRole role;
        address id_;
        string name;
        string email;
    }

    struct UserHistory {
        address id_; // account Id of the user
        uint256 date; // Added, Purchased date in epoch in UTC timezone
    }

    struct ProductHistory {
        UserHistory manufacturer;
        UserHistory supplier;
        UserHistory vendor;
        UserHistory[] customers;
    }

    struct Product {
        string name;
        string manufacturerName;
        address manufacturer;
        bool isInBatch;
        uint256 batchCount;
        string barcodeId;
    }
}
