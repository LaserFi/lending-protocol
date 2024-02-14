// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../PriceOracle.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

interface ICToken {
    function underlying() external view returns (address);
}

contract PythPriceOracle is PriceOracle {
    IPyth public immutable pyth;
    mapping(string => bytes32) public assetIds;
    mapping(string => uint256) public baseUnits;

    constructor(
        IPyth _pyth,
        string[] memory symbols_,
        bytes32[] memory feeds_,
        uint256[] memory baseUnits_
    ) {
        require(symbols_.length == feeds_.length && symbols_.length == baseUnits_.length && symbols_.length > 0, "wrong args");

        for (uint256 i = 0; i < symbols_.length; i++) {
            assetIds[symbols_[i]] = feeds_[i];
            baseUnits[symbols_[i]] = baseUnits_[i];
        }
        pyth = _pyth;
    }

    // price in 18 decimals
    function getPrice(CToken cToken) public view returns (uint256) {
        string memory symbol = cToken.symbol();

        (uint256 price, ) = _getLatestPrice(symbol);

        return price;
    }

    // price is extended for comptroller usage based on decimals of exchangeRate
    function getUnderlyingPrice(CToken cToken)
        external
        view
        override
        returns (uint256)
    {
        string memory symbol = cToken.symbol();
       
        (uint256 price, ) = _getLatestPrice(symbol);
        return (price * 1e18 / baseUnits[symbol]);
    }

    function _getLatestPrice(string memory symbol)
        public
        view
        returns (uint256, uint256)
    {
        require(assetIds[symbol] != 0x0, "missing priceFeed");

        PythStructs.Price memory data = pyth.getPriceUnsafe(
            assetIds[symbol]
        );

        require(data.price > 0, "price cannot be zero");
        uint256 uPrice = uint256(uint64(data.price)) * 1e18 / 10**uint256(uint32(-data.expo));


        return (uPrice, data.publishTime);
    }

    function getRawPrice(CToken cToken) public view returns (PythStructs.Price memory data) {
        string memory symbol = cToken.symbol();

        data = pyth.getPrice(
            assetIds[symbol]
        );
    }

    function getRawPriceUnsafe(CToken cToken) public view returns (PythStructs.Price memory data) {
        string memory symbol = cToken.symbol();

        data = pyth.getPriceUnsafe(
            assetIds[symbol]
        );
    }
}
