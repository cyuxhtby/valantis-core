// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { ALMCachedLiquidityQuote, ALMReserves } from '../../ALM/structs/UniversalALMStructs.sol';
import { IUniversalOracle } from '../../oracles/interfaces/IUniversalOracle.sol';
import { SwapFeeModuleData } from '../../swap-fee-modules/interfaces/ISwapFeeModule.sol';

// compactly stores AML metadata into a single 32-byte slot
struct Slot0 {
    bool isMetaALM; // A MetaALM is an ALM that interacts with and aggregates liquidity from other ALMs
    bool isCallbackOnSwapEndRequired;
    bool shareQuotes; // will base ALMs share quote information with meta ALMs in exchange for a share of the fees
    uint64 metaALMFeeShare; // percentage of fees that a meta ALM shares with base ALMs, if applicable
    address almAddress;
}

struct ALMPosition {
    Slot0 slot0; // AML metadata of respective position
    uint256 reserve0;
    uint256 reserve1;
    uint256 feeCumulative0;
    uint256 feeCumulative1;
}

// A tokenOutAmount quote from an underlying ALM to a MetaALM
struct UnderlyingALMQuote {
    bool isValidQuote;
    address almAddress;
    uint256 tokenOutAmount;
}

struct MetaALMData {
    UnderlyingALMQuote[] almQuotes;
    bytes almContext; // possible extra parameters or settings specific to the metaALM's liquidity aggregation
}

struct SwapParams {
    bool isZeroToOne;
    bool isSwapCallback;
    int24 limitPriceTick;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMin;
    uint256 deadline;
    bytes swapCallbackContext;
    bytes swapFeeModuleContext;
    uint8[] almOrdering;  // ordering during setupSwap, specified by the pool manager
    bytes[] externalContext; // possibly off-chain data or additional params ? 
}

/************************************************
 *  CACHE STRUCTS
 ***********************************************/

struct SwapCache {
    bool isMetaALMPool;
    int24 spotPriceTick;
    int24 spotPriceTickStart;
    address swapFeeModule;
    uint256 amountInMinusFee;
    uint256 amountInRemaining;
    uint256 amountOutFilled;
    uint256 effectiveFee; // actual swap fee charged
    uint256 numBaseALMs; // number of ALMs that are not meta ALMs
    uint256 baseShareQuoteLiquidity; // total liquidity provided by base ALMs sharing quotes
    uint256 feeInBips;
}

// internal state for an ALM during a swap
struct InternalSwapALMState {
    bool isParticipatingInSwap;
    bool refreshReserves;
    Slot0 almSlot0;
    uint256 totalLiquidityProvided;
    uint256 totalLiquidityReceived;
    ALMReserves almReserves;
    uint256 feeEarned;
    ALMCachedLiquidityQuote latestLiquidityQuote;
}

struct PoolState {
    uint256 poolManagerFeeBips;
    uint256 feeProtocol0;
    uint256 feeProtocol1;
    uint256 feePoolManager0;
    uint256 feePoolManager1;
    uint256 swapFeeModuleUpdateTimestamp;
    address swapFeeModule;
    address poolManager;
    address universalOracle;
    address gauge;
}

enum ALMStatus {
    NULL, // ALM was never added to the pool
    ACTIVE, // ALM was added to the pool, and is in operation
    REMOVED // ALM was added to the pool, and then removed, not in operation
}
