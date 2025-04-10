import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { AgentDetailsUpdated } from "../generated/schema"
import { AgentDetailsUpdated as AgentDetailsUpdatedEvent } from "../generated/TripleACollectionManager/TripleACollectionManager"
import { handleAgentDetailsUpdated } from "../src/triple-a-collection-manager"
import { createAgentDetailsUpdatedEvent } from "./triple-a-collection-manager-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let sender = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let customInstructions = ["Example string value"]
    let agentIds = [BigInt.fromI32(234)]
    let collectionId = BigInt.fromI32(234)
    let newAgentDetailsUpdatedEvent = createAgentDetailsUpdatedEvent(
      sender,
      customInstructions,
      agentIds,
      collectionId
    )
    handleAgentDetailsUpdated(newAgentDetailsUpdatedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("AgentDetailsUpdated created and stored", () => {
    assert.entityCount("AgentDetailsUpdated", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "AgentDetailsUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "sender",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "AgentDetailsUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "customInstructions",
      "[Example string value]"
    )
    assert.fieldEquals(
      "AgentDetailsUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "agentIds",
      "[234]"
    )
    assert.fieldEquals(
      "AgentDetailsUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "collectionId",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
