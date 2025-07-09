// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract Counter {
    uint private counter;

    constructor() {
        counter = 0;
    }

    function count() public {
        counter = counter + 1;
    }

    function add(uint x) public {
        counter = counter + x;
    }

    function get() public view returns (uint) {
        return counter;
    }
}