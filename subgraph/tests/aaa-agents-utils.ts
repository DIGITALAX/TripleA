import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AgentCreated,
  AgentDeleted,
  AgentEdited,
  BalanceAdded,
  BalanceWithdrawn
} from "../generated/AAAAgents/AAAAgents"

export function createAgentCreatedEvent(
  wallet: Address,
  creator: Address,
  id: BigInt
): AgentCreated {
  let agentCreatedEvent = changetype<AgentCreated>(newMockEvent())

  agentCreatedEvent.parameters = new Array()

  agentCreatedEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
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

export function createBalanceAddedEvent(
  token: Address,
  agentId: BigInt,
  amount: BigInt
): BalanceAdded {
  let balanceAddedEvent = changetype<BalanceAdded>(newMockEvent())

  balanceAddedEvent.parameters = new Array()

  balanceAddedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  balanceAddedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  balanceAddedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return balanceAddedEvent
}

export function createBalanceWithdrawnEvent(
  token: Address,
  agentId: BigInt,
  amount: BigInt
): BalanceWithdrawn {
  let balanceWithdrawnEvent = changetype<BalanceWithdrawn>(newMockEvent())

  balanceWithdrawnEvent.parameters = new Array()

  balanceWithdrawnEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  balanceWithdrawnEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  balanceWithdrawnEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return balanceWithdrawnEvent
}
