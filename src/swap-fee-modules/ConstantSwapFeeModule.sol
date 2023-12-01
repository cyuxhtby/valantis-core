// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { SwapFeeModuleData } from 'src/swap-fee-modules/interfaces/ISwapFeeModule.sol';
import { IConstantSwapFeeModule } from 'src/swap-fee-modules/interfaces/IConstantSwapFeeModule.sol';

contract ConstantSwapFeeModule is IConstantSwapFeeModule {
    /************************************************
     *  CUSTOM ERRORS
     ***********************************************/

    error ConstantSwapFeeModule__onlyPool();
    error ConstantSwapFeeModule__onlyFeeModuleManager();
    error ConstantSwapFeeModule__invalidSwapFeeBips();

    /************************************************
     *  CONSTANTS
     ***********************************************/

    uint256 public constant MAX_SWAP_FEE_BIPS = 10_000;

    /************************************************
     *  IMMUTABLES
     ***********************************************/

    address public immutable pool;

    /************************************************
     *  STORAGE
     ***********************************************/

    address public feeModuleManager;

    uint256 public swapFeeBips;

    /************************************************
     *  MODIFIERS
     ***********************************************/

    function _onlyPool() private view {
        if (msg.sender != pool) {
            revert ConstantSwapFeeModule__onlyPool();
        }
    }

    function _onlyFeeModuleManager() private view {
        if (msg.sender != feeModuleManager) {
            revert ConstantSwapFeeModule__onlyFeeModuleManager();
        }
    }

    modifier onlyPool() {
        _onlyPool();
        _;
    }

    modifier onlyFeeModuleManager() {
        _onlyFeeModuleManager();
        _;
    }

    /************************************************
     *  CONSTRUCTOR
     ***********************************************/

    constructor(address _pool, uint256 _swapFeeBips, address _feeModuleManager) {
        if (_swapFeeBips > MAX_SWAP_FEE_BIPS) {
            revert ConstantSwapFeeModule__invalidSwapFeeBips();
        }

        pool = _pool;
        swapFeeBips = _swapFeeBips;
        feeModuleManager = _feeModuleManager;
    }

    /************************************************
     *  EXTERNAL FUNCTIONS
     ***********************************************/

    /**
        @notice Update address of Swap Fee Module manager.
        @dev Only callable by `feeModuleManager`.
        @param _feeModuleManager Address of new `feeModuleManager`. 
     */
    function setFeeModuleManager(address _feeModuleManager) external onlyFeeModuleManager {
        feeModuleManager = _feeModuleManager;
    }

    /**
        @notice Update constant swap fee in basis points.
        @dev Only callable by `feeModuleManager.
        @param _swapFeeBips New constant swap fee in basis points. 
     */
    function setSwapFeeBips(uint256 _swapFeeBips) external onlyFeeModuleManager {
        if (_swapFeeBips > MAX_SWAP_FEE_BIPS) {
            revert ConstantSwapFeeModule__invalidSwapFeeBips();
        }

        swapFeeBips = _swapFeeBips;
    }

    /**
        @notice Calculate swap fee.
        @dev Only callable by `pool`.
        @return swapFeeModuleData Swap Fee Module data. 
     */
    function getSwapFeeInBips(
        bool,
        uint256,
        address,
        bytes memory
    ) external view override onlyPool returns (SwapFeeModuleData memory swapFeeModuleData) {
        swapFeeModuleData.feeInBips = swapFeeBips;
        swapFeeModuleData.internalContext = new bytes(0);
    }

    /**
        @notice Callback after the swap is ended for Universal Pool.
        @dev Not applicable for this Swap Fee Module. 
     */
    function callbackOnSwapEnd(uint256, int24, uint256, uint256, SwapFeeModuleData memory) external override onlyPool {}

    /**
        @notice Callback after the swap is ended for SovereignPool
        @dev Not applicable for this Swap Fee Module. 
     */
    function callbackOnSwapEnd(uint256, uint256, uint256, SwapFeeModuleData memory) external override onlyPool {}
}
