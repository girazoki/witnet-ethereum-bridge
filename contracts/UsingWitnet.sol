pragma solidity ^0.5.0;

import "./WitnetBridgeInterface.sol";


contract UsingWitnet{

    WitnetBridgeInterface wbi;

    constructor (address _wbi) public {
        wbi = WitnetBridgeInterface(_wbi);
    }

    function witnetPostDataRequest(bytes memory _dr, uint256 _tallie_reward) public payable returns(uint256 id){
        return wbi.post_dr.value(msg.value)(_dr, _tallie_reward);
    }

    function witnetUpgradeDataRequest(uint256 _id, uint256 _tallie_reward) public payable {
        wbi.upgrade_dr.value(msg.value)(_id, _tallie_reward);
    }

    function witnetReadResult (uint256 _id) public view returns(bytes memory){
        return wbi.read_result(_id);
    }
}
