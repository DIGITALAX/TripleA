import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  FulfillerCreated,
  FulfillerDeleted,
  OrderAdded,
  OrderFulfilled
} from "../generated/TripleAFulfillerManager/TripleAFulfillerManager"

export function createFulfillerCreatedEvent(
  wallet: Address,
  fulfillerId: BigInt
): FulfillerCreated {
  let fulfillerCreatedEvent = changetype<FulfillerCreated>(newMockEvent())

  fulfillerCreatedEvent.parameters = new Array()

  fulfillerCreatedEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  fulfillerCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillerId",
      ethereum.Value.fromUnsignedBigInt(fulfillerId)
    )
  )

  return fulfillerCreatedEvent
}

export function createFulfillerDeletedEvent(
  fulfillerId: BigInt
): FulfillerDeleted {
  let fulfillerDeletedEvent = changetype<FulfillerDeleted>(newMockEvent())

  fulfillerDeletedEvent.parameters = new Array()

  fulfillerDeletedEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillerId",
      ethereum.Value.fromUnsignedBigInt(fulfillerId)
    )
  )

  return fulfillerDeletedEvent
}

export function createOrderAddedEvent(
  fulfillerId: BigInt,
  orderId: BigInt
): OrderAdded {
  let orderAddedEvent = changetype<OrderAdded>(newMockEvent())

  orderAddedEvent.parameters = new Array()

  orderAddedEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillerId",
      ethereum.Value.fromUnsignedBigInt(fulfillerId)
    )
  )
  orderAddedEvent.parameters.push(
    new ethereum.EventParam(
      "orderId",
      ethereum.Value.fromUnsignedBigInt(orderId)
    )
  )

  return orderAddedEvent
}

export function createOrderFulfilledEvent(
  fulfillerId: BigInt,
  orderId: BigInt
): OrderFulfilled {
  let orderFulfilledEvent = changetype<OrderFulfilled>(newMockEvent())

  orderFulfilledEvent.parameters = new Array()

  orderFulfilledEvent.parameters.push(
    new ethereum.EventParam(
      "fulfillerId",
      ethereum.Value.fromUnsignedBigInt(fulfillerId)
    )
  )
  orderFulfilledEvent.parameters.push(
    new ethereum.EventParam(
      "orderId",
      ethereum.Value.fromUnsignedBigInt(orderId)
    )
  )

  return orderFulfilledEvent
}
