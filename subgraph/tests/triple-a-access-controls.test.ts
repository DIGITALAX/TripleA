import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { AdminAdded } from "../generated/schema"
import { AdminAdded as AdminAddedEvent } from "../generated/TripleAAccessControls/TripleAAccessControls"
import { handleAdminAdded } from "../src/triple-a-access-controls"
import { createAdminAddedEvent } from "./triple-a-access-controls-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let admin = Address.fromString("0x0000000000000000000000000000000000000001")
    let newAdminAddedEvent = createAdminAddedEvent(admin)
    handleAdminAdded(newAdminAddedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("AdminAdded created and stored", () => {
    assert.entityCount("AdminAdded", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "AdminAdded",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "admin",
      "0x0000000000000000000000000000000000000001"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
