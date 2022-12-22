// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2LinearTest } from "../SablierV2LinearTest.t.sol";

contract IsEntity__Test is SablierV2LinearTest {
    /// @dev it should return false.
    function testIsEntity__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        bool isEntity = sablierV2Linear.isEntity(nonStreamId);
        assertFalse(isEntity);
    }

    modifier StreamExistent() {
        _;
    }

    /// @dev it should return true.
    function testIsEntity() external StreamExistent {
        uint256 defaultStreamId = createDefaultStream();
        bool isEntity = sablierV2Linear.isEntity(defaultStreamId);
        assertTrue(isEntity);
    }
}
