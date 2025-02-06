import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { AddAgentWallet } from "../generated/schema"
import { AddAgentWallet as AddAgentWalletEvent } from "../generated/SkyhuntersAgentManager/SkyhuntersAgentManager"
import { handleAddAgentWallet } from "../src/skyhunters-agent-manager"
import { createAddAgentWalletEvent } from "./skyhunters-agent-manager-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let wallet = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let agentId = BigInt.fromI32(234)
    let newAddAgentWalletEvent = createAddAgentWalletEvent(wallet, agentId)
    handleAddAgentWallet(newAddAgentWalletEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("AddAgentWallet created and stored", () => {
    assert.entityCount("AddAgentWallet", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "AddAgentWallet",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "wallet",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "AddAgentWallet",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "agentId",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
