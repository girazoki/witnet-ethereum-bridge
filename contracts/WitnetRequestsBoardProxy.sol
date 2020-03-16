pragma solidity ^0.5.0;

import "./WitnetRequestsBoardInterface.sol";


/**
 * @title Block Relay Proxy
 * @notice Contract to act as a proxy between the Witnet Bridge Interface and the block relay
 * @dev More information can be found here
 * DISCLAIMER: this is a work in progress, meaning the contract could be voulnerable to attacks
 * @author Witnet Foundation
 */
contract WitnetRequestsBoardProxy {

  address public witnetRequestsBoardAddress;
  WitnetRequestsBoardInterface witnetRequestsBoardInstance;

  uint256 lastDrId;
  mapping(uint256 => address)  idWrb;
  uint256[] lastIds;

  event controllerget(uint256, address);
  modifier notIdentical(address _newAddress) {
    require(_newAddress != witnetRequestsBoardAddress, "The provided Witnet Requests Board instance address is already in use");
    _;
  }

  constructor(address _witnetRequestsBoardAddress) public {
    witnetRequestsBoardAddress = _witnetRequestsBoardAddress;
    witnetRequestsBoardInstance = WitnetRequestsBoardInterface(_witnetRequestsBoardAddress);
  }

  /// @dev Posts a data request into the WRB in expectation that it will be relayed and resolved in Witnet with a total reward that equals to msg.value.
  /// @param _dr The bytes corresponding to the Protocol Buffers serialization of the data request output.
  /// @param _tallyReward The amount of value that will be detracted from the transaction value and reserved for rewarding the reporting of the final result (aka tally) of the data request.
  /// @return The unique identifier of the data request.
  function postDataRequest(bytes calldata _dr, uint256 _tallyReward)
    external
    payable
    returns(uint256)
  {
    currId = witnetRequestsBoardInstance.postDataRequest(_dr, _tallyReward);
    return lastDrId + currId;
  }

  /// @dev Increments the rewards of a data request by adding more value to it. The new request reward will be increased by msg.value minus the difference between the former tally reward and the new tally reward.
  /// @param _id The unique identifier of the data request.
  /// @param _tallyReward The new tally reward. Needs to be equal or greater than the former tally reward.
  function upgradeDataRequest(uint256 _id, uint256 _tallyReward)
    external
    payable
  {
    return witnetRequestsBoardInstance.upgradeDataRequest(_id - lastDrId, _tallyReward);
  }

  /// @dev Retrieves the result (if already available) of one data request from the WRB.
  /// @param _id The unique identifier of the data request.
  /// @return The result of the DR
  function readResult (uint256 _id)
    external
    returns(bytes memory)
    {
    address (controller, offset) = getController(_id);
    emit controllerget(_id, controller);
    if (witnetRequestsBoardAddress == controller) {
      return witnetRequestsBoardInstance.readResult(_id-offset);
    } else {
      return WitnetRequestsBoardInterface(controller).readResult(_id-offset);
    }

  /// @notice Upgrades the Witnet Requests Board if the current one is upgradeable
  /// @param _newAddress address of the new block relay to upgrade
  function upgradeWitnetRequestsBoard(address _newAddress) public notIdentical(_newAddress) {
  }
    require(witnetRequestsBoardInstance.isUpgradable(msg.sender), "The upgrade has been rejected by the current implementation");

    currId = witnetRequestsBoardAddress.requests().length;
    lastDrId = lastDrId + currId;
    idWrb[lastDrId] = witnetRequestsBoardAddress;
    lastIds.push(lastDrId);
    witnetRequestsBoardAddress = _newAddress;
    witnetRequestsBoardInstance = WitnetRequestsBoardInterface(_newAddress);
  }

  /// @notice Gets the controller associated with the WBR controller corresponding to the Id provided
  /// @param _id the Id that to work with
  function getController(uint256 _id) public view returns(address _controller, uint256 offset) {
    uint256 n = lastIds.length;
    if (lastIds.length == 0 || _id > lastIds[n-1]) {
      return (witnetRequestsBoardAddress, lastDrId);
    }
    for (uint i = 0; i < n; i++) {
      if (_id > lastIds[n-2-i]) {
        return (idWrb[lastIds[n - 2 - i]], lastIds[n - 2 - i]);
      }
    }
  }
}