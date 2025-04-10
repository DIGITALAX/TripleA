import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AddAgentWallet,
  AddOwner,
  AgentCreated,
  AgentDeleted,
  AgentEdited,
  AgentScored,
  AgentSetActive,
  AgentSetInactive,
  RevokeAgentWallet,
  RevokeOwner
} from "../generated/SkyhuntersAgentManager/SkyhuntersAgentManager"

export function createAddAgentWalletEvent(
  wallet: Address,
  agentId: BigInt
): AddAgentWallet {
  let addAgentWalletEvent = changetype<AddAgentWallet>(newMockEvent())

  addAgentWalletEvent.parameters = new Array()

  addAgentWalletEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  addAgentWalletEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return addAgentWalletEvent
}

export function createAddOwnerEvent(
  wallet: Address,
  agentId: BigInt
): AddOwner {
  let addOwnerEvent = changetype<AddOwner>(newMockEvent())

  addOwnerEvent.parameters = new Array()

  addOwnerEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  addOwnerEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return addOwnerEvent
}

export function createAgentCreatedEvent(
  wallets: Array<Address>,
  creator: Address,
  id: BigInt
): AgentCreated {
  let agentCreatedEvent = changetype<AgentCreated>(newMockEvent())

  agentCreatedEvent.parameters = new Array()

  agentCreatedEvent.parameters.push(
    new ethereum.EventParam("wallets", ethereum.Value.fromAddressArray(wallets))
  )
  agentCreatedEvent.parameters.push(
    new ethereum.EventParam("creator", ethereum.Value.fromAddress(creator))
  )
  agentCreatedEvent.parameters.push(
    new ethereum.EventParam("id", ethereum.Value.fromUnsignedBigInt(id))
  )

  return agentCreatedEvent
}

export function createAgentDeletedEvent(id: BigInt): AgentDeleted {
  let agentDeletedEvent = changetype<AgentDeleted>(newMockEvent())

  agentDeletedEvent.parameters = new Array()

  agentDeletedEvent.parameters.push(
    new ethereum.EventParam("id", ethereum.Value.fromUnsignedBigInt(id))
  )

  return agentDeletedEvent
}

export function createAgentEditedEvent(id: BigInt): AgentEdited {
  let agentEditedEvent = changetype<AgentEdited>(newMockEvent())

  agentEditedEvent.parameters = new Array()

  agentEditedEvent.parameters.push(
    new ethereum.EventParam("id", ethereum.Value.fromUnsignedBigInt(id))
  )

  return agentEditedEvent
}

export function createAgentScoredEvent(
  scorer: Address,
  agentId: BigInt,
  score: BigInt,
  positive: boolean
): AgentScored {
  let agentScoredEvent = changetype<AgentScored>(newMockEvent())

  agentScoredEvent.parameters = new Array()

  agentScoredEvent.parameters.push(
    new ethereum.EventParam("scorer", ethereum.Value.fromAddress(scorer))
  )
  agentScoredEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  agentScoredEvent.parameters.push(
    new ethereum.EventParam("score", ethereum.Value.fromUnsignedBigInt(score))
  )
  agentScoredEvent.parameters.push(
    new ethereum.EventParam("positive", ethereum.Value.fromBoolean(positive))
  )

  return agentScoredEvent
}

export function createAgentSetActiveEvent(
  wallet: Address,
  agentId: BigInt
): AgentSetActive {
  let agentSetActiveEvent = changetype<AgentSetActive>(newMockEvent())

  agentSetActiveEvent.parameters = new Array()

  agentSetActiveEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  agentSetActiveEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return agentSetActiveEvent
}

export function createAgentSetInactiveEvent(
  wallet: Address,
  agentId: BigInt
): AgentSetInactive {
  let agentSetInactiveEvent = changetype<AgentSetInactive>(newMockEvent())

  agentSetInactiveEvent.parameters = new Array()

  agentSetInactiveEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  agentSetInactiveEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return agentSetInactiveEvent
}

export function createRevokeAgentWalletEvent(
  wallet: Address,
  agentId: BigInt
): RevokeAgentWallet {
  let revokeAgentWalletEvent = changetype<RevokeAgentWallet>(newMockEvent())

  revokeAgentWalletEvent.parameters = new Array()

  revokeAgentWalletEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  revokeAgentWalletEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return revokeAgentWalletEvent
}

export function createRevokeOwnerEvent(
  wallet: Address,
  agentId: BigInt
): RevokeOwner {
  let revokeOwnerEvent = changetype<RevokeOwner>(newMockEvent())

  revokeOwnerEvent.parameters = new Array()

  revokeOwnerEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  revokeOwnerEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return revokeOwnerEvent
}
