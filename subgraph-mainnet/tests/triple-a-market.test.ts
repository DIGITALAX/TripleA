import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { CollectionPurchased } from "../generated/schema"
import { CollectionPurchased as CollectionPurchasedEvent } from "../generated/TripleAMarket/TripleAMarket"
import { handleCollectionPurchased } from "../src/triple-a-market"
import { createCollectionPurchasedEvent } from "./triple-a-market-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let buyer = Address.fromString("0x0000000000000000000000000000000000000001")
    let paymentToken = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let orderId = BigInt.fromI32(234)
    let collectionId = BigInt.fromI32(234)
    let amount = BigInt.fromI32(234)
    let artistShare = BigInt.fromI32(234)
    let fulfillerShare = BigInt.fromI32(234)
    let agentShare = BigInt.fromI32(234)
    let remixShare = BigInt.fromI32(234)
    let newCollectionPurchasedEvent = createCollectionPurchasedEvent(
      buyer,
      paymentToken,
      orderId,
      collectionId,
      amount,
      artistShare,
      fulfillerShare,
      agentShare,
      remixShare
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
      "buyer",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "paymentToken",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "orderId",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "collectionId",
      "234"
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
      "artistShare",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "fulfillerShare",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "agentShare",
      "234"
    )
    assert.fieldEquals(
      "CollectionPurchased",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "remixShare",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
