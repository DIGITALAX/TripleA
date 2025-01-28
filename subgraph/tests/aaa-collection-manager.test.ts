import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { CollectionDeleted } from "../generated/schema"
import { CollectionDeleted as CollectionDeletedEvent } from "../generated/AAACollectionManager/AAACollectionManager"
import { handleCollectionDeleted } from "../src/aaa-collection-manager"
import { createCollectionDeletedEvent } from "./aaa-collection-manager-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let artist = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let collectionId = BigInt.fromI32(234)
    let newCollectionDeletedEvent = createCollectionDeletedEvent(
      artist,
      collectionId
    )
    handleCollectionDeleted(newCollectionDeletedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("CollectionDeleted created and stored", () => {
    assert.entityCount("CollectionDeleted", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "CollectionDeleted",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "artist",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "CollectionDeleted",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "collectionId",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
