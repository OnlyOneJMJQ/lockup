// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/core/libraries/Errors.sol";

import { Lockup_Integration_Shared_Test } from "../../../shared/lockup/Lockup.t.sol";
import { Integration_Test } from "../../../Integration.t.sol";

abstract contract IsCancelable_Integration_Concrete_Test is Integration_Test, Lockup_Integration_Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override(Integration_Test, Lockup_Integration_Shared_Test) { }

    function test_RevertGiven_Null() external {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierLockup_Null.selector, nullStreamId));
        lockup.isCancelable(nullStreamId);
    }

    modifier givenNotNull() {
        defaultStreamId = createDefaultStream();
        _;
    }

    function test_GivenColdStream() external givenNotNull {
        vm.warp({ newTimestamp: defaults.END_TIME() }); // settled status
        bool isCancelable = lockup.isCancelable(defaultStreamId);
        assertFalse(isCancelable, "isCancelable");
    }

    modifier givenWarmStream() {
        _;
    }

    function test_GivenCancelableStream() external givenNotNull givenWarmStream {
        bool isCancelable = lockup.isCancelable(defaultStreamId);
        assertTrue(isCancelable, "isCancelable");
    }

    function test_GivenNonCancelableStream() external givenNotNull givenWarmStream {
        uint256 streamId = createDefaultStreamNotCancelable();
        bool isCancelable = lockup.isCancelable(streamId);
        assertFalse(isCancelable, "isCancelable");
    }
}
