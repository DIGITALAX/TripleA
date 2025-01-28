import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { AgentFundsWithdrawn } from "../generated/schema"
import { AgentFundsWithdrawn as AgentFundsWithdrawnEvent } from "../generated/AAADevTreasury/AAADevTreasury"
import { handleAgentFundsWithdrawn } from "../src/aaa-dev-treasury"
import { createAgentFundsWithdrawnEvent } from "./aaa-dev-treasury-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let tokens = [
      Address.fromString("0x0000000000000000000000000000000000000001")
    ]
    let amounts = [BigInt.fromI32(234)]
    let agent = Address.fromString("0x0000000000000000000000000000000000000001")
    let newAgentFundsWithdrawnEvent = createAgentFundsWithdrawnEvent(
      tokens,
      amounts,
      agent
    )
    handleAgentFundsWithdrawn(newAgentFundsWithdrawnEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("AgentFundsWithdrawn created and stored", () => {
    assert.entityCount("AgentFundsWithdrawn", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "AgentFundsWithdrawn",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "tokens",
      "[0x0000000000000000000000000000000000000001]"
    )
    assert.fieldEquals(
      "AgentFundsWithdrawn",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amounts",
      "[234]"
    )
    assert.fieldEquals(
      "AgentFundsWithdrawn",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "agent",
      "0x0000000000000000000000000000000000000001"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
