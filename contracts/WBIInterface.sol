pragma solidity ^0.5.0;
/**
 * @title WBI Interface
 * @notice Interface of a WBI
 * It defines how to interact with the WBI in order to support:
 *  - Post and upgrade a data request
 *  - Read the result of a dr
 * @author Witnet Foundation
 */
interface WBIInterface {

  /// @dev Posts a data request into the WBI in expectation that it will be relayed and resolved in Witnet with a total reward that equals to msg.value.
  /// @param _dr The bytes corresponding to the Protocol Buffers serialization of the data request output.
  /// @param _tallyReward The amount of value that will be detracted from the transaction value and reserved for rewarding the reporting of the final result (aka tally) of the data request.
  /// @return The unique identifier of the data request.
  function postDataRequest(bytes calldata _dr, uint256 _tallyReward)
    external
    payable
    returns(uint256);

  /// @dev Increments the rewards of a data request by adding more value to it. The new request reward will be increased by msg.value minus the difference between the former tally reward and the new tally reward.
  /// @param _id The unique identifier of the data request.
  /// @param _tallyReward The new tally reward. Needs to be equal or greater than the former tally reward.
  function upgradeDataRequest(uint256 _id, uint256 _tallyReward)
    external
    payable;

  /// @dev Retrieves the result (if already available) of one data request from the WBI.
  /// @param _id The unique identifier of the data request.
  /// @return The result of the DR
  function readResult (uint256 _id) external view returns(bytes memory);

}