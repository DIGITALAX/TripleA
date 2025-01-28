import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import { CollectionPurchased } from "../generated/AAAMarket/AAAMarket"

export function createCollectionPurchasedEvent(
  collectionId: BigInt,
  buyer: Address,
  amount: BigInt,
  paymentToken: Address
): CollectionPurchased {
  let collectionPurchasedEvent = changetype<CollectionPurchased>(newMockEvent())

  collectionPurchasedEvent.parameters = new Array()

  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam("buyer", ethereum.Value.fromAddress(buyer))
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  collectionPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "paymentToken",
      ethereum.Value.fromAddress(paymentToken)
    )
  )

  return collectionPurchasedEvent
}
