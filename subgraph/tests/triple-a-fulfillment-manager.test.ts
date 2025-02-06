import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { FulfillerCreated } from "../generated/schema"
import { FulfillerCreated as FulfillerCreatedEvent } from "../generated/TripleAFulfillerManager/TripleAFulfillerManager"
import { handleFulfillerCreated } from "../src/triple-a-fulfiller-manager"
import { createFulfillerCreatedEvent } from "./triple-a-fulfillment-manager-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let wallet = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let fulfillerId = BigInt.fromI32(234)
    let newFulfillerCreatedEvent = createFulfillerCreatedEvent(
      wallet,
      fulfillerId
    )
    handleFulfillerCreated(newFulfillerCreatedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("FulfillerCreated created and stored", () => {
    assert.entityCount("FulfillerCreated", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "FulfillerCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "wallet",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "FulfillerCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "fulfillerId",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
