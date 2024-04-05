// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";

interface IComp {
    function getAccountLiquidity(
        address account
    ) external view returns (uint256, uint256, uint256);

    function getAssetsIn(
        address account
    ) external view returns (CToken[] memory);
}

contract CallAggregator {
    struct CTokensData {
        uint256 balance;
        uint256 borrow;
        uint256 exchangeRate;
    }

    struct ComptData {
        uint256 liquidity;
        uint256 debt;
        CToken[] markets;
    }

    function getUserData(
        address _comptroller,
        address[] calldata _cTokens,
        address _account
    )
        external
        view
        returns (ComptData memory comptData, CTokensData[] memory cTokensData)
    {
        // Get data from comptroller
        (, comptData.liquidity, comptData.debt) = IComp(_comptroller)
            .getAccountLiquidity(_account);
        comptData.markets = IComp(_comptroller).getAssetsIn(_account);

        // Get data from cTokens
        cTokensData = new CTokensData[](_cTokens.length);
        for (uint256 i = 0; i < cTokensData.length; i++) {
            CTokensData memory _data;
            (, _data.balance, _data.borrow, _data.exchangeRate) = CToken(
                _cTokens[i]
            ).getAccountSnapshot(_account);
            cTokensData[i] = _data;
        }
    }
}
