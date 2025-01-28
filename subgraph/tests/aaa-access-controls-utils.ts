import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AcceptedTokenRemoved,
  AcceptedTokenSet,
  AdminAdded,
  AdminRemoved,
  AgentAdded,
  AgentRemoved,
  FaucetUsed,
  TokenThresholdSet
} from "../generated/AAAAccessControls/AAAAccessControls"

export function createAcceptedTokenRemovedEvent(
  token: Address
): AcceptedTokenRemoved {
  let acceptedTokenRemovedEvent = changetype<AcceptedTokenRemoved>(
    newMockEvent()
  )

  acceptedTokenRemovedEvent.parameters = new Array()

  acceptedTokenRemovedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )

  return acceptedTokenRemovedEvent
}

export function createAcceptedTokenSetEvent(token: Address): AcceptedTokenSet {
  let acceptedTokenSetEvent = changetype<AcceptedTokenSet>(newMockEvent())

  acceptedTokenSetEvent.parameters = new Array()

  acceptedTokenSetEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )

  return acceptedTokenSetEvent
}

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

export function createAgentAddedEvent(agent: Address): AgentAdded {
  let agentAddedEvent = changetype<AgentAdded>(newMockEvent())

  agentAddedEvent.parameters = new Array()

  agentAddedEvent.parameters.push(
    new ethereum.EventParam("agent", ethereum.Value.fromAddress(agent))
  )

  return agentAddedEvent
}

export function createAgentRemovedEvent(agent: Address): AgentRemoved {
  let agentRemovedEvent = changetype<AgentRemoved>(newMockEvent())

  agentRemovedEvent.parameters = new Array()

  agentRemovedEvent.parameters.push(
    new ethereum.EventParam("agent", ethereum.Value.fromAddress(agent))
  )

  return agentRemovedEvent
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

export function createTokenThresholdSetEvent(
  token: Address,
  threshold: BigInt,
  rent: BigInt
): TokenThresholdSet {
  let tokenThresholdSetEvent = changetype<TokenThresholdSet>(newMockEvent())

  tokenThresholdSetEvent.parameters = new Array()

  tokenThresholdSetEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  tokenThresholdSetEvent.parameters.push(
    new ethereum.EventParam(
      "threshold",
      ethereum.Value.fromUnsignedBigInt(threshold)
    )
  )
  tokenThresholdSetEvent.parameters.push(
    new ethereum.EventParam("rent", ethereum.Value.fromUnsignedBigInt(rent))
  )

  return tokenThresholdSetEvent
}
