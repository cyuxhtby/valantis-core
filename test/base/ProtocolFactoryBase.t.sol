// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { ProtocolFactory } from 'src/protocol-factory/ProtocolFactory.sol';

import { Base } from 'test/base/Base.sol';
import { ProtocolFactoryDeployer } from 'test/deployers/ProtocolFactoryDeployer.sol';

contract ProtocolFactoryBase is Base, ProtocolFactoryDeployer {
    ProtocolFactory public protocolFactory;

    bool public isAuctionControllerInitialized;

    function setUp() public {
        _setupBase();

        protocolFactory = deployProtocolFactory();
    }

    function initiateAuctionController() external {
        assertEq(msg.sender, address(protocolFactory));

        isAuctionControllerInitialized = true;
    }
}
