import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AdminAdded,
  AdminRemoved,
  FaucetUsed,
  FulfillerAdded,
  FulfillerRemoved,
  TokenDetailsRemoved,
  TokenDetailsSet
} from "../generated/TripleAAccessControls/TripleAAccessControls"

export function createAdminAddedEvent(admin: Address): AdminAdded {
  let adminAddedEvent = changetype<AdminAdded>(newMockEvent())

  adminAddedEvent.parameters = new Array()

  adminAddedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return adminAddedEvent
}

export function createAdminRemovedEvent(admin: Address): AdminRemoved {
  let adminRemovedEvent = changetype<AdminRemoved>(newMockEvent())

  adminRemovedEvent.parameters = new Array()

  adminRemovedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return adminRemovedEvent
}

export function createFaucetUsedEvent(to: Address, amount: BigInt): FaucetUsed {
  let faucetUsedEvent = changetype<FaucetUsed>(newMockEvent())

  faucetUsedEvent.parameters = new Array()

  faucetUsedEvent.parameters.push(
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to))
  )
  faucetUsedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return faucetUsedEvent
}

export function createFulfillerAddedEvent(admin: Address): FulfillerAdded {
  let fulfillerAddedEvent = changetype<FulfillerAdded>(newMockEvent())

  fulfillerAddedEvent.parameters = new Array()

  fulfillerAddedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return fulfillerAddedEvent
}

export function createFulfillerRemovedEvent(admin: Address): FulfillerRemoved {
  let fulfillerRemovedEvent = changetype<FulfillerRemoved>(newMockEvent())

  fulfillerRemovedEvent.parameters = new Array()

  fulfillerRemovedEvent.parameters.push(
    new ethereum.EventParam("admin", ethereum.Value.fromAddress(admin))
  )

  return fulfillerRemovedEvent
}

export function createTokenDetailsRemovedEvent(
  token: Address
): TokenDetailsRemoved {
  let tokenDetailsRemovedEvent = changetype<TokenDetailsRemoved>(newMockEvent())

  tokenDetailsRemovedEvent.parameters = new Array()

  tokenDetailsRemovedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )

  return tokenDetailsRemovedEvent
}

export function createTokenDetailsSetEvent(
  token: Address,
  threshold: BigInt,
  rentLead: BigInt,
  rentRemix: BigInt,
  rentPublish: BigInt,
  rentMint: BigInt,
  vig: BigInt,
  base: BigInt
): TokenDetailsSet {
  let tokenDetailsSetEvent = changetype<TokenDetailsSet>(newMockEvent())

  tokenDetailsSetEvent.parameters = new Array()

  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam(
      "threshold",
      ethereum.Value.fromUnsignedBigInt(threshold)
    )
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam(
      "rentLead",
      ethereum.Value.fromUnsignedBigInt(rentLead)
    )
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam(
      "rentRemix",
      ethereum.Value.fromUnsignedBigInt(rentRemix)
    )
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam(
      "rentPublish",
      ethereum.Value.fromUnsignedBigInt(rentPublish)
    )
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam(
      "rentMint",
      ethereum.Value.fromUnsignedBigInt(rentMint)
    )
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam("vig", ethereum.Value.fromUnsignedBigInt(vig))
  )
  tokenDetailsSetEvent.parameters.push(
    new ethereum.EventParam("base", ethereum.Value.fromUnsignedBigInt(base))
  )

  return tokenDetailsSetEvent
}
