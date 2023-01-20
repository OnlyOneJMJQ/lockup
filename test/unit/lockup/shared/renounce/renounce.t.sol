// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { Events } from "src/libraries/Events.sol";

import { Shared_Test } from "../SharedTest.t.sol";

abstract contract Renounce_Test is Shared_Test {
    uint256 internal defaultStreamId;

    function setUp() public virtual override {
        super.setUp();

        // Create the default stream.
        defaultStreamId = createDefaultStream();
    }

    modifier streamNotActive() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_StreamNull() external streamNotActive {
        uint256 nullStreamId = 1729;
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamNotActive.selector, nullStreamId));
        lockup.renounce(nullStreamId);
    }

    /// @dev it should revert.
    function test_RevertWhen_StreamCanceled() external streamNotActive {
        lockup.cancel(defaultStreamId);
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamNotActive.selector, defaultStreamId));
        lockup.renounce(defaultStreamId);
    }

    /// @dev it should revert.
    function test_RevertWhen_StreamDepleted() external streamNotActive {
        vm.warp({ timestamp: DEFAULT_STOP_TIME });
        lockup.withdrawMax({ streamId: defaultStreamId, to: users.recipient });
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_StreamNotActive.selector, defaultStreamId));
        lockup.renounce(defaultStreamId);
    }

    modifier streamActive() {
        // Create the default stream.
        defaultStreamId = createDefaultStream();
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_CallerNotSender(address eve) external streamActive {
        vm.assume(eve != address(0) && eve != users.sender);

        // Make Eve the caller in this test.
        changePrank(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2Lockup_Unauthorized.selector, defaultStreamId, eve));
        lockup.renounce(defaultStreamId);
    }

    modifier callerSender() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_NonCancelableStream() external streamActive callerSender {
        // Create the non-cancelable stream.
        uint256 nonCancelableStreamId = createDefaultStreamNonCancelable();

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierV2Lockup_RenounceNonCancelableStream.selector, nonCancelableStreamId)
        );
        lockup.renounce(nonCancelableStreamId);
    }

    /// @dev it should renounce the stream and emit a {RenounceLockupStream} event.
    function test_Renounce() external streamActive callerSender {
        // Expect a {RenounceLockupStream} event to be emitted.
        vm.expectEmit({ checkTopic1: true, checkTopic2: false, checkTopic3: false, checkData: false });
        emit Events.RenounceLockupStream(defaultStreamId);

        // RenounceLockupStream the stream.
        lockup.renounce(defaultStreamId);

        // Assert that the stream is non-cancelable now.
        bool isCancelable = lockup.isCancelable(defaultStreamId);
        assertFalse(isCancelable, "isCancelable");
    }
}
