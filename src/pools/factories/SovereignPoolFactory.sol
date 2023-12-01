// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { IPoolDeployer } from 'src/protocol-factory/interfaces/IPoolDeployer.sol';

import { SovereignPool } from 'src/pools/SovereignPool.sol';
import { SovereignPoolConstructorArgs } from 'src/pools/structs/SovereignPoolStructs.sol';

contract SovereignPoolFactory is IPoolDeployer {
    /************************************************
     *  STORAGE
     ***********************************************/

    /**
        @notice Nonce used to derive unique CREATE2 salts. 
     */
    uint256 public nonce;

    /************************************************
     *  EXTERNAL FUNCTIONS
     ***********************************************/

    function deploy(bytes32, bytes calldata _constructorArgs) external override returns (address deployment) {
        SovereignPoolConstructorArgs memory args = abi.decode(_constructorArgs, (SovereignPoolConstructorArgs));

        // Salt to trigger a create2 deployment,
        // as create is prone to re-org attacks
        bytes32 salt = keccak256(abi.encode(nonce));
        deployment = address(new SovereignPool{ salt: salt }(args));

        nonce++;
    }
}
