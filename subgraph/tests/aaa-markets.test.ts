import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { BigInt, Address } from "@graphprotocol/graph-ts"
import { CollectionPurchased } from "../generated/schema"
import { CollectionPurchased as CollectionPurchasedEvent } from "../generated/AAAMarket/AAAMarket"
import { handleCollectionPurchased } from "../src/aaa-market"
import { createCollectionPurchasedEvent } from "./aaa-market-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let collectionId = BigInt.fromI32(234)
    let buyer = Address.fromString("0x0000000000000000000000000000000000000001")
    let amount = BigInt.fromI32(234)
    let paymentToken = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let newCollectionPurchasedEvent = createCollectionPurchasedEvent(
      collectionId,
      buyer,
      amount,
      paymentToken
    )
    handleCollectionPurchased(newCollectionPurchasedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("CollectionPurchased created and stored", () => {
    assert.entityCount("CollectionPurchased", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "collectionId",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "buyer",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amount",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "paymentToken",
      "0x0000000000000000000000000000000000000001"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
