// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ABIEncoder {
    function encodeUint(uint256 value) public pure returns (bytes memory) {
        return abi.encode(value);
    }

    function encodeMultiple(
        uint num,
        string memory text
    ) public pure returns (bytes memory) {
       //
       return abi.encode(num,text);
    }
}

contract ABIDecoder {
    function decodeUint(bytes memory data) public pure returns (uint) {
        //
        return abi.decode(data,(uint));
    }

    function decodeMultiple(
        bytes memory data
    ) public pure returns (uint, string memory) {
        //
        return abi.decode(data, (uint,string));
    }
}

contract FunctionSelector {
    uint256 private storedValue;

    function getValue() public view returns (uint) {
        return storedValue;
    }

    function setValue(uint value) public {
        storedValue = value;
    }

    function getFunctionSelector1() public pure returns (bytes4) {
        //
        return bytes4(abi.encodeWithSignature("getValue()"));
    }

    function getFunctionSelector2() public pure returns (bytes4) {
        //
        return  bytes4(abi.encodeWithSignature("setValue(uint)"));
    }

    function comp() public pure returns(bytes4){
        return ABIDecoder.decodeUint.selector;
    }
}

contract DataStorage {
    string private data;

    function setData(string memory newData) public {
        data = newData;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

contract DataConsumer {
    address private dataStorageAddress;
    string public mydata;

    constructor(address _dataStorageAddress) {
        dataStorageAddress = _dataStorageAddress;
    }
// 补充完整getDataByABI，对getData函数签名及参数进行编码，调用成功后解码并返回数据
// 补充完整setDataByABI1，使用abi.encodeWithSignature()编码调用setData函数，确保调用能够成功
// 补充完整setDataByABI2，使用abi.encodeWithSelector()编码调用setData函数，确保调用能够成功
// 补充完整setDataByABI3，使用abi.encodeCall()编码调用setData函数，确保调用能够成功
    function getDataByABI() public returns (string memory) {
        // payload
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, bytes memory data) = dataStorageAddress.call(payload);
        require(success, "call function failed");
        //mydata = abi.decode(data,(string));
        // mydata = string(data);
        return string(abi.decode(data,(string)));
    }

    function setDataByABI1(string calldata newData) public returns (bool) {
        // payload
        bytes memory payload = abi.encodeWithSignature("setData(string)", newData);
        (bool success, ) = dataStorageAddress.call(payload);

        return success;
    }

    function setDataByABI2(string calldata newData) public returns (bool) {
        // selector
        bytes4 selector = bytes4(keccak256("setData(string)"));
        // payload
        bytes memory payload = abi.encodeWithSelector(selector,newData);

        (bool success, ) = dataStorageAddress.call(payload);

        return success;
    }

    function setDataByABI3(string calldata newData) public returns (bool) {
        // payload
        bytes memory payload = abi.encodeCall(DataStorage.setData,newData);
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }
}

contract Callee {
    function getData() public pure returns (uint256) {
        return 42;
    }
}

contract Caller {
    function callGetData(address callee) public view returns (uint256 data) {
        // call by staticcall
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, bytes memory tmpdata) = callee.staticcall(payload);
        require(success,"staticcall function failed");
        data = abi.decode(tmpdata,(uint256));
        return data;
    }
}

contract Caller4 {
    function sendEther(address to, uint256 value) public payable returns (bool) {
        // 使用 call 发送 ether
        // 如果发送失败，抛出“sendEther failed”异常并回滚交易。
        // 如果发送成功，则返回 true
        (bool success, ) = to.call{value: value*10**18}(new bytes(0));
        require(success,"sendEther failed");
        return success;
    }

    receive() external payable {}
}

contract Callee5 {
    uint256 value;

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 value_) public payable {
        require(msg.value > 0);
        value = value_;
    }
}

contract Caller5 {
    function callSetValue(address callee, uint256 value) public returns (bool) {
        // call setValue()
        // 使用 call 方法调用用 Callee 的 setValue 方法，并附带 1 Ether
        // 如果发送失败，抛出“call function failed”异常并回滚交易。
        // 如果发送成功，则返回 true
        (bool success, ) = callee.call{value: 1 ether}(abi.encodeWithSignature("setValue(uint256)", value));
        require(success,"sendEther failed");
        return success;
    }
    function tt() public payable {}
}


contract Callee6 {
    uint256 public value;

    function setValue(uint256 _newValue) public {
        value = _newValue;
    }
}

contract Caller6 {
    uint256 public value;

    function delegateSetValue(address callee, uint256 _newValue) public {
        // delegatecall setValue()
        // 使用 delegatecall
        // 如果发送失败，抛出“delegate call failed”异常并回滚交易
        (bool success, ) = callee.delegatecall(abi.encodeWithSignature("setValue(uint256)", _newValue));
        require(success,"delegate call failed");
    }
}