import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  ActivateAgent,
  AgentPaidRent,
  AgentRecharged,
  BalanceAdded,
  RewardsCalculated,
  WorkerAdded,
  WorkerUpdated
} from "../generated/TripleAAgents/TripleAAgents"

export function createActivateAgentEvent(
  wallet: Address,
  agentId: BigInt
): ActivateAgent {
  let activateAgentEvent = changetype<ActivateAgent>(newMockEvent())

  activateAgentEvent.parameters = new Array()

  activateAgentEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  activateAgentEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return activateAgentEvent
}

export function createAgentPaidRentEvent(
  tokens: Array<Address>,
  collectionIds: Array<BigInt>,
  amounts: Array<BigInt>,
  bonuses: Array<BigInt>,
  agentId: BigInt
): AgentPaidRent {
  let agentPaidRentEvent = changetype<AgentPaidRent>(newMockEvent())

  agentPaidRentEvent.parameters = new Array()

  agentPaidRentEvent.parameters.push(
    new ethereum.EventParam("tokens", ethereum.Value.fromAddressArray(tokens))
  )
  agentPaidRentEvent.parameters.push(
    new ethereum.EventParam(
      "collectionIds",
      ethereum.Value.fromUnsignedBigIntArray(collectionIds)
    )
  )
  agentPaidRentEvent.parameters.push(
    new ethereum.EventParam(
      "amounts",
      ethereum.Value.fromUnsignedBigIntArray(amounts)
    )
  )
  agentPaidRentEvent.parameters.push(
    new ethereum.EventParam(
      "bonuses",
      ethereum.Value.fromUnsignedBigIntArray(bonuses)
    )
  )
  agentPaidRentEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return agentPaidRentEvent
}

export function createAgentRechargedEvent(
  recharger: Address,
  token: Address,
  agentId: BigInt,
  collectionId: BigInt,
  amount: BigInt
): AgentRecharged {
  let agentRechargedEvent = changetype<AgentRecharged>(newMockEvent())

  agentRechargedEvent.parameters = new Array()

  agentRechargedEvent.parameters.push(
    new ethereum.EventParam("recharger", ethereum.Value.fromAddress(recharger))
  )
  agentRechargedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  agentRechargedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  agentRechargedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  agentRechargedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return agentRechargedEvent
}

export function createBalanceAddedEvent(
  token: Address,
  agentId: BigInt,
  amount: BigInt,
  collectionId: BigInt
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
  balanceAddedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return balanceAddedEvent
}

export function createRewardsCalculatedEvent(
  token: Address,
  amount: BigInt
): RewardsCalculated {
  let rewardsCalculatedEvent = changetype<RewardsCalculated>(newMockEvent())

  rewardsCalculatedEvent.parameters = new Array()

  rewardsCalculatedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  rewardsCalculatedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return rewardsCalculatedEvent
}

export function createWorkerAddedEvent(
  agentId: BigInt,
  collectionId: BigInt
): WorkerAdded {
  let workerAddedEvent = changetype<WorkerAdded>(newMockEvent())

  workerAddedEvent.parameters = new Array()

  workerAddedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  workerAddedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return workerAddedEvent
}

export function createWorkerUpdatedEvent(
  agentId: BigInt,
  collectionId: BigInt
): WorkerUpdated {
  let workerUpdatedEvent = changetype<WorkerUpdated>(newMockEvent())

  workerUpdatedEvent.parameters = new Array()

  workerUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  workerUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return workerUpdatedEvent
}
