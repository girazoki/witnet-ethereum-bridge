const truffleAssert = require("truffle-assertions")
const WitnetRequestsBoardV1 = artifacts.require("WitnetRequestsBoardV1")
const WitnetRequestsBoardV2 = artifacts.require("WitnetRequestsBoardV2")
const WitnetRequestsBoardProxy = artifacts.require("WitnetRequestsBoardProxy")
const MockBlockRelay = artifacts.require("MockBlockRelay")

contract("Witnet Requests Board Proxy", accounts => {
  describe("Witnet Requests Board Proxy test suite", () => {
    let blockRelay
    let wrbInstance1
    let wrbInstance2
    let wrbProxy

    before(async () => {
      blockRelay = await MockBlockRelay.new({
        from: accounts[0],
      })
      wrbInstance1 = await WitnetRequestsBoardV1.new(blockRelay.address, 1, {
        from: accounts[0],
      })
      wrbInstance2 = await WitnetRequestsBoardV2.new(blockRelay.address, 1, {
        from: accounts[0],
      })
      wrbProxy = await WitnetRequestsBoardProxy.new(wrbInstance1.address, {
        from: accounts[0],
      })
    })

    it("should revert when trying to upgrade the same WRB", async () => {
      // It should revert because the WRB to be upgrated is already in use
      await truffleAssert.reverts(
        wrbProxy.upgradeWitnetRequestsBoard(wrbInstance1.address),
        "The provided Witnet Requests Board instance address is already in use")
    })

    it("should post a data request and read the result", async () => {
      const drBytes = web3.utils.fromAscii("This is a DR")
      const halfEther = web3.utils.toWei("0.5", "ether")
      // Post first data request
      const tx1 = wrbProxy.postDataRequest(drBytes, halfEther, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })

      const txHash1 = await waitForHash(tx1)
      const txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id1 = txReceipt1.logs[0].data

      assert.equal(id1, 1)
      //   result of first data request
      const tx2 = wrbInstance1.postResult(id1, web3.utils.fromAscii("result"))
      await waitForHash(tx2)

      const postedResult = await wrbProxy.readResult.call(id1)

      assert.equal(postedResult, web3.utils.fromAscii("result"))
    })

    it("should change the address of the WBRcontroller", async () => {
      // Set the wrbIntance2 to be the WRB in the proxy contract
      assert(wrbProxy.witnetRequestsBoardAddress(), wrbInstance1.address)
      await wrbProxy.upgradeWitnetRequestsBoard(wrbInstance2.address, {
        from: accounts[0],
      })
      assert(wrbProxy.witnetRequestsBoardAddress(), wrbInstance2.address)
      //await truffleAssert.reverts(wrbProxy.upgradeWitnetRequestsBoard(wrbInstance1.address),  "The upgrade has been rejected by the current implementation")
    })

    it("should post a data request and read the result in the second controller", async () => {
      const drBytes = web3.utils.fromAscii("This is a DR")
      const halfEther = web3.utils.toWei("0.5", "ether")
      // Post first data request
      const tx1 = wrbProxy.postDataRequest(drBytes, halfEther, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })

      const txHash1 = await waitForHash(tx1)
      const txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id2 = txReceipt1.logs[0].data

      assert.equal(id2, 2)
      //   result of first data request
      const tx2 = wrbInstance1.postResult(id2, web3.utils.fromAscii("result"))
      await waitForHash(tx2)

      const postedResult = await wrbProxy.readResult.call(id2)

      assert.equal(postedResult, web3.utils.fromAscii("testInstanceV2"))
    })
  })
})


const waitForHash = txQ =>
  new Promise((resolve, reject) =>
    txQ.on("transactionHash", resolve).catch(reject)
  )
