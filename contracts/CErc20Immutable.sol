// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CErc20.sol";

/**
 * @title Compound's CErc20Immutable Contract
 * @notice CTokens which wrap an EIP-20 underlying and are immutable
 * @author Compound
 */
contract CErc20Immutable is CErc20 {
    /**
     * @notice Construct a new money market
     * @param underlying_ The address of the underlying asset
     * @param comptroller_ The address of the Comptroller
     * @param interestRateModel_ The address of the interest rate model
     * @param initialExchangeRateMantissa_ The initial exchange rate, scaled by 1e18
     * @param name_ ERC-20 name of this token
     * @param symbol_ ERC-20 symbol of this token
     * @param decimals_ ERC-20 decimal precision of this token
     * @param admin_ Address of the administrator of this token
     */
    constructor(address underlying_,
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_,
                address _pointsOperator) {
        // Creator of the contract is admin during initialization
        admin = payable(msg.sender);

        // Initialize the market
        initialize(underlying_, comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        // Set the proper admin now that initialization is done
        admin = admin_;

        // Blast fancy
        IBlastPoints(0x2fc95838c71e76ec69ff817983BFf17c710F34E0).configurePointsOperator(_pointsOperator);
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas(); 
        IERC20Rebasing(0x4200000000000000000000000000000000000022).configure(YieldMode.CLAIMABLE);
    }

    /**
     * @notice Admin only blast integration
     * @param _receiver Treasury address
     */
    function _claimAllYields(address _receiver) external {
        if (msg.sender != admin) {
            revert ("Admin check");
        }
        IBlast(0x4300000000000000000000000000000000000002).claimAllGas(address(this), _receiver);
        uint256 amount = IERC20Rebasing(0x4300000000000000000000000000000000000004).getClaimableAmount(address(this));
        IERC20Rebasing(0x4300000000000000000000000000000000000004).claim(_receiver, amount);
    }
}
