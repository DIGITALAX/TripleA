import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  CollectionPurchased,
  FulfillmentUpdated
} from "../generated/TripleAMarket/TripleAMarket"

export function createCollectionPurchasedEvent(
  buyer: Address,
  paymentToken: Address,
  orderId: BigInt,
  collectionId: BigInt,
  amount: BigInt,
  artistShare: BigInt,
  fulfillerShare: BigInt
): CollectionPurchased {
  let collectionPurchasedEvent = changetype<CollectionPurchased>(newMockEvent())

  collectionPurchasedEvent.parameters = new Array()

  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam("buyer", ethereum.Value.fromAddress(buyer))
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "paymentToken",
      ethereum.Value.fromAddress(paymentToken)
    )
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "orderId",
      ethereum.Value.fromUnsignedBigInt(orderId)
    )
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "artistShare",
      ethereum.Value.fromUnsignedBigInt(artistShare)
    )
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillerShare",
      ethereum.Value.fromUnsignedBigInt(fulfillerShare)
    )
  )

  return collectionPurchasedEvent
}

export function createFulfillmentUpdatedEvent(
  fulfillment: string,
  orderId: BigInt
): FulfillmentUpdated {
  let fulfillmentUpdatedEvent = changetype<FulfillmentUpdated>(newMockEvent())

  fulfillmentUpdatedEvent.parameters = new Array()

  fulfillmentUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillment",
      ethereum.Value.fromString(fulfillment)
    )
  )
  fulfillmentUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "orderId",
      ethereum.Value.fromUnsignedBigInt(orderId)
    )
  )

  return fulfillmentUpdatedEvent
}
