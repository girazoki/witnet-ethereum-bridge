const WBI = artifacts.require("WitnetBridgeInterface")
const truffleAssert = require("truffle-assertions")
const sha = require("js-sha256")

var wait = ms => new Promise((resolve, reject) => setTimeout(resolve, ms))

contract("WBI", accounts => {
  describe("WBI test suite", () => {
    let wbiInstance
    beforeEach(async () => {
      wbiInstance = await WBI.new()
    })

    it("should allow post and read drs", async () => {
      // Take current balance
      var account1 = accounts[0]
      let actualBalance1 = await web3.eth.getBalance(account1)

      const drBytes = web3.utils.fromAscii("This is a DR")
      const drBytes2 = web3.utils.fromAscii("This is a second DR")

      const half_ether = web3.utils.toWei("0.5", "ether")

      const tx1 = wbiInstance.post_dr(drBytes, half_ether, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })
      const txHash1 = await waitForHash(tx1)
      let txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id1 = txReceipt1.logs[0].data

      const tx2 = wbiInstance.post_dr(drBytes2, 0)
      const txHash2 = await waitForHash(tx2)
      let txReceipt2 = await web3.eth.getTransactionReceipt(txHash2)
      const id2 = txReceipt2.logs[0].data

      let readDrBytes = await wbiInstance.read_dr.call(id1)
      let readDrBytes2 = await wbiInstance.read_dr.call(id2)

      let afterBalance1 = await web3.eth.getBalance(account1)
      let contractBalanceAfter = await web3.eth.getBalance(
        wbiInstance.address
      )

      assert(parseInt(afterBalance1, 10) < parseInt(actualBalance1, 10))
      assert.equal(web3.utils.toWei("1", "ether"), contractBalanceAfter)

      assert.equal(drBytes, readDrBytes)
      assert.equal(drBytes2, readDrBytes2)
    })

    it("should upgrade the reward of the data request in the contract", async () => {     
      const drBytes = web3.utils.fromAscii("This is a DR")
      const half_ether = web3.utils.toWei("0.5", "ether")
      // one ether to the dr reward
      const tx1 = wbiInstance.post_dr(drBytes, half_ether, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })
      const txHash1 = await waitForHash(tx1)
      let txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id1 = txReceipt1.logs[0].data

      let contractBalanceBefore = await web3.eth.getBalance(
        wbiInstance.address
      )
      assert.equal(web3.utils.toWei("1", "ether"), contractBalanceBefore)

      const tx2 = wbiInstance.upgrade_dr(id1, half_ether, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })
      await waitForHash(tx2)

      let contractBalanceAfter = await web3.eth.getBalance(
        wbiInstance.address
      )

      assert.equal(web3.utils.toWei("2", "ether"), contractBalanceAfter)
    })

    it("should allow post and read result", async () => {
      var account1 = accounts[0]
      var account2 = accounts[1]
      let actualBalance1 = await web3.eth.getBalance(account1)
      let actualBalance2 = await web3.eth.getBalance(account2)

      const drBytes = web3.utils.fromAscii("This is a DR")
      const resBytes = web3.utils.fromAscii("This is a result")
      const half_ether = web3.utils.toWei("0.5", "ether")

      const tx1 = wbiInstance.post_dr(drBytes, half_ether, {
        from: account1,
        value: web3.utils.toWei("1", "ether"),
      })
      const txHash1 = await waitForHash(tx1)
      let txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id1 = txReceipt1.logs[0].data

      const tx2 = wbiInstance.claim_drs([id1], resBytes, {
        from: account2,
      })


      const txHash2 = await waitForHash(tx2)
      
      const tx3 = wbiInstance.report_dr_inclusion(id1, resBytes, 1, {
        from: account2,
      })

      const txHash3 = await waitForHash(tx3)
      const afterBalance2 = await web3.eth.getBalance(account2)
      assert(parseInt(afterBalance2, 10) > parseInt(actualBalance2, 10))


      // report result
      let restx = wbiInstance.report_result(id1, resBytes, 1, resBytes, { from: account2 })
      await waitForHash(restx)

      let afterBalance1 = await web3.eth.getBalance(account1)
      let balance_final = await web3.eth.getBalance(account2)
      let contractBalanceAfter = await web3.eth.getBalance(
        wbiInstance.address
      )

      assert(parseInt(afterBalance1, 10) < parseInt(actualBalance1, 10))
      assert(parseInt(balance_final, 10) > parseInt(afterBalance2, 10))

      assert.equal(0, contractBalanceAfter)

      let readResBytes = await wbiInstance.read_result.call(id1)
      assert.equal(resBytes, readResBytes)
    })

    it("should return the data request id", async () => {
      const drBytes1 = web3.utils.fromAscii("This is a DR")
      const drBytes2 = web3.utils.fromAscii("This is a second DR")
      const half_ether = web3.utils.toWei("0.5", "ether")
      const tx1 = wbiInstance.post_dr(drBytes1, half_ether, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })
      const txHash1 = await waitForHash(tx1)
      let txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      const id1 = txReceipt1.logs[0].data
      assert.equal(web3.utils.hexToNumberString(id1), web3.utils.hexToNumberString(sha.sha256("This is a DR")))

      const tx2 = wbiInstance.post_dr(drBytes2, 0)
      const txHash2 = await waitForHash(tx2)
      let txReceipt2 = await web3.eth.getTransactionReceipt(txHash2)
      let id2 = txReceipt2.logs[0].data
      assert.equal(web3.utils.hexToNumberString(id2), web3.utils.hexToNumberString(sha.sha256("This is a second DR")))

      let readDrBytes1 = await wbiInstance.read_dr.call(id1)
      let readDrBytes2 = await wbiInstance.read_dr.call(id2)
      assert.equal(drBytes1, readDrBytes1)
      assert.equal(drBytes2, readDrBytes2)
    })

    it("should emit an event with the id", async () => {
      const drBytes = web3.utils.fromAscii("This is a DR")
      const hash = sha.sha256("This is a DR")
      const expected_result_id = web3.utils.hexToNumberString(hash)
      const tx = await wbiInstance.post_dr(drBytes,0)
      truffleAssert.eventEmitted(tx, "PostDataRequest", (ev) => {
        return ev[1].toString() === expected_result_id
      })
      let readDrBytes = await wbiInstance.read_dr.call(expected_result_id)
      assert.equal(drBytes, readDrBytes)
    })

    it("should subscribe to an event, wait for its emision, and read result", async () => {
      const drBytes = web3.utils.fromAscii("This is a DR")
      const resBytes = web3.utils.fromAscii("This is a result")
      const half_ether = web3.utils.toWei("0.5", "ether")

      const tx1 = wbiInstance.post_dr(drBytes, half_ether, {
        from: accounts[0],
        value: web3.utils.toWei("1", "ether"),
      })
      const txHash1 = await waitForHash(tx1)
      let txReceipt1 = await web3.eth.getTransactionReceipt(txHash1)
      let data1 = txReceipt1.logs[0].data
      assert.equal(web3.utils.hexToNumberString(data1), web3.utils.hexToNumberString(sha.sha256("This is a DR")))
      // Subscribe to PostResult event
      wbiInstance.PostResult({}, async (_error, event) => {
        let readresBytes1 = await wbiInstance.read_result.call(data1)
        assert.equal(resBytes, readresBytes1)
      })

      const tx2 = wbiInstance.claim_drs([data1], resBytes, {
        from: accounts[1],
      })
      const txHash2 = await waitForHash(tx2)

      const tx3 = wbiInstance.report_dr_inclusion(data1, resBytes, 1, {
        from: accounts[1],
      })
      const txHash3 = await waitForHash(tx3)      

      const tx4 = await wbiInstance.report_result(data1, resBytes, 1, resBytes)
      // wait for the async method to finish
      await wait(500)
      truffleAssert.eventEmitted(tx4, "PostResult", (ev) => {
        return ev[1].eq(web3.utils.toBN(data1))
      })
    })
  })
})

const waitForHash = txQ =>
  new Promise((resolve, reject) =>
    txQ.on("transactionHash", resolve).catch(reject)
  )
