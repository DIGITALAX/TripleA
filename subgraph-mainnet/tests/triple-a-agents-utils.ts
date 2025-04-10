import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  ActivateAgent,
  AgentMarketWalletEdited,
  AgentPaidRent,
  AgentRecharged,
  ArtistCollectBalanceAdded,
  ArtistCollectBalanceSpent,
  ArtistPaid,
  BalanceAdded,
  BalanceTransferred,
  CollectorPaid,
  DevTreasuryPaid,
  OwnerPaid,
  RewardsCalculated,
  ServicesAdded,
  ServicesWithdrawn,
  WorkerAdded,
  WorkerRemoved,
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

export function createAgentMarketWalletEditedEvent(
  wallet: Address,
  agentId: BigInt
): AgentMarketWalletEdited {
  let agentMarketWalletEditedEvent =
    changetype<AgentMarketWalletEdited>(newMockEvent())

  agentMarketWalletEditedEvent.parameters = new Array()

  agentMarketWalletEditedEvent.parameters.push(
    new ethereum.EventParam("wallet", ethereum.Value.fromAddress(wallet))
  )
  agentMarketWalletEditedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return agentMarketWalletEditedEvent
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

export function createArtistCollectBalanceAddedEvent(
  forArtist: Address,
  token: Address,
  agentId: BigInt,
  amount: BigInt
): ArtistCollectBalanceAdded {
  let artistCollectBalanceAddedEvent =
    changetype<ArtistCollectBalanceAdded>(newMockEvent())

  artistCollectBalanceAddedEvent.parameters = new Array()

  artistCollectBalanceAddedEvent.parameters.push(
    new ethereum.EventParam("forArtist", ethereum.Value.fromAddress(forArtist))
  )
  artistCollectBalanceAddedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  artistCollectBalanceAddedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  artistCollectBalanceAddedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return artistCollectBalanceAddedEvent
}

export function createArtistCollectBalanceSpentEvent(
  forArtist: Address,
  to: Address,
  token: Address,
  agentId: BigInt,
  collectionId: BigInt,
  amount: BigInt
): ArtistCollectBalanceSpent {
  let artistCollectBalanceSpentEvent =
    changetype<ArtistCollectBalanceSpent>(newMockEvent())

  artistCollectBalanceSpentEvent.parameters = new Array()

  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam("forArtist", ethereum.Value.fromAddress(forArtist))
  )
  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to))
  )
  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  artistCollectBalanceSpentEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return artistCollectBalanceSpentEvent
}

export function createArtistPaidEvent(
  forArtist: Address,
  token: Address,
  agentId: BigInt,
  collectionId: BigInt,
  amount: BigInt
): ArtistPaid {
  let artistPaidEvent = changetype<ArtistPaid>(newMockEvent())

  artistPaidEvent.parameters = new Array()

  artistPaidEvent.parameters.push(
    new ethereum.EventParam("forArtist", ethereum.Value.fromAddress(forArtist))
  )
  artistPaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  artistPaidEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  artistPaidEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  artistPaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return artistPaidEvent
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

export function createBalanceTransferredEvent(
  artist: Address,
  agentId: BigInt
): BalanceTransferred {
  let balanceTransferredEvent = changetype<BalanceTransferred>(newMockEvent())

  balanceTransferredEvent.parameters = new Array()

  balanceTransferredEvent.parameters.push(
    new ethereum.EventParam("artist", ethereum.Value.fromAddress(artist))
  )
  balanceTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )

  return balanceTransferredEvent
}

export function createCollectorPaidEvent(
  collector: Address,
  token: Address,
  amount: BigInt,
  collectionId: BigInt
): CollectorPaid {
  let collectorPaidEvent = changetype<CollectorPaid>(newMockEvent())

  collectorPaidEvent.parameters = new Array()

  collectorPaidEvent.parameters.push(
    new ethereum.EventParam("collector", ethereum.Value.fromAddress(collector))
  )
  collectorPaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  collectorPaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  collectorPaidEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return collectorPaidEvent
}

export function createDevTreasuryPaidEvent(
  token: Address,
  amount: BigInt,
  collectionId: BigInt
): DevTreasuryPaid {
  let devTreasuryPaidEvent = changetype<DevTreasuryPaid>(newMockEvent())

  devTreasuryPaidEvent.parameters = new Array()

  devTreasuryPaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  devTreasuryPaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  devTreasuryPaidEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return devTreasuryPaidEvent
}

export function createOwnerPaidEvent(
  owner: Address,
  token: Address,
  amount: BigInt,
  collectionId: BigInt
): OwnerPaid {
  let ownerPaidEvent = changetype<OwnerPaid>(newMockEvent())

  ownerPaidEvent.parameters = new Array()

  ownerPaidEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  ownerPaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  ownerPaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )
  ownerPaidEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return ownerPaidEvent
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

export function createServicesAddedEvent(
  token: Address,
  amount: BigInt
): ServicesAdded {
  let servicesAddedEvent = changetype<ServicesAdded>(newMockEvent())

  servicesAddedEvent.parameters = new Array()

  servicesAddedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  servicesAddedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return servicesAddedEvent
}

export function createServicesWithdrawnEvent(
  token: Address,
  amount: BigInt
): ServicesWithdrawn {
  let servicesWithdrawnEvent = changetype<ServicesWithdrawn>(newMockEvent())

  servicesWithdrawnEvent.parameters = new Array()

  servicesWithdrawnEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  servicesWithdrawnEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return servicesWithdrawnEvent
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

export function createWorkerRemovedEvent(
  agentId: BigInt,
  collectionId: BigInt
): WorkerRemoved {
  let workerRemovedEvent = changetype<WorkerRemoved>(newMockEvent())

  workerRemovedEvent.parameters = new Array()

  workerRemovedEvent.parameters.push(
    new ethereum.EventParam(
      "agentId",
      ethereum.Value.fromUnsignedBigInt(agentId)
    )
  )
  workerRemovedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return workerRemovedEvent
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
