import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  AgentDetailsUpdated,
  CollectionActivated,
  CollectionCreated,
  CollectionDeactivated,
  CollectionDeleted,
  CollectionPriceAdjusted,
  DropCreated,
  DropDeleted,
  Remixable
} from "../generated/TripleACollectionManager/TripleACollectionManager"

export function createAgentDetailsUpdatedEvent(
  customInstructions: Array<string>,
  agentIds: Array<BigInt>,
  collectionId: BigInt
): AgentDetailsUpdated {
  let agentDetailsUpdatedEvent = changetype<AgentDetailsUpdated>(newMockEvent())

  agentDetailsUpdatedEvent.parameters = new Array()

  agentDetailsUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "customInstructions",
      ethereum.Value.fromStringArray(customInstructions)
    )
  )
  agentDetailsUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "agentIds",
      ethereum.Value.fromUnsignedBigIntArray(agentIds)
    )
  )
  agentDetailsUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return agentDetailsUpdatedEvent
}

export function createCollectionActivatedEvent(
  collectionId: BigInt
): CollectionActivated {
  let collectionActivatedEvent = changetype<CollectionActivated>(newMockEvent())

  collectionActivatedEvent.parameters = new Array()

  collectionActivatedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return collectionActivatedEvent
}

export function createCollectionCreatedEvent(
  artist: Address,
  collectionId: BigInt,
  dropId: BigInt
): CollectionCreated {
  let collectionCreatedEvent = changetype<CollectionCreated>(newMockEvent())

  collectionCreatedEvent.parameters = new Array()

  collectionCreatedEvent.parameters.push(
    new ethereum.EventParam("artist", ethereum.Value.fromAddress(artist))
  )
  collectionCreatedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  collectionCreatedEvent.parameters.push(
    new ethereum.EventParam("dropId", ethereum.Value.fromUnsignedBigInt(dropId))
  )

  return collectionCreatedEvent
}

export function createCollectionDeactivatedEvent(
  collectionId: BigInt
): CollectionDeactivated {
  let collectionDeactivatedEvent = changetype<CollectionDeactivated>(
    newMockEvent()
  )

  collectionDeactivatedEvent.parameters = new Array()

  collectionDeactivatedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return collectionDeactivatedEvent
}

export function createCollectionDeletedEvent(
  artist: Address,
  collectionId: BigInt
): CollectionDeleted {
  let collectionDeletedEvent = changetype<CollectionDeleted>(newMockEvent())

  collectionDeletedEvent.parameters = new Array()

  collectionDeletedEvent.parameters.push(
    new ethereum.EventParam("artist", ethereum.Value.fromAddress(artist))
  )
  collectionDeletedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )

  return collectionDeletedEvent
}

export function createCollectionPriceAdjustedEvent(
  token: Address,
  collectionId: BigInt,
  newPrice: BigInt
): CollectionPriceAdjusted {
  let collectionPriceAdjustedEvent = changetype<CollectionPriceAdjusted>(
    newMockEvent()
  )

  collectionPriceAdjustedEvent.parameters = new Array()

  collectionPriceAdjustedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  collectionPriceAdjustedEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  collectionPriceAdjustedEvent.parameters.push(
    new ethereum.EventParam(
      "newPrice",
      ethereum.Value.fromUnsignedBigInt(newPrice)
    )
  )

  return collectionPriceAdjustedEvent
}

export function createDropCreatedEvent(
  artist: Address,
  dropId: BigInt
): DropCreated {
  let dropCreatedEvent = changetype<DropCreated>(newMockEvent())

  dropCreatedEvent.parameters = new Array()

  dropCreatedEvent.parameters.push(
    new ethereum.EventParam("artist", ethereum.Value.fromAddress(artist))
  )
  dropCreatedEvent.parameters.push(
    new ethereum.EventParam("dropId", ethereum.Value.fromUnsignedBigInt(dropId))
  )

  return dropCreatedEvent
}

export function createDropDeletedEvent(
  artist: Address,
  dropId: BigInt
): DropDeleted {
  let dropDeletedEvent = changetype<DropDeleted>(newMockEvent())

  dropDeletedEvent.parameters = new Array()

  dropDeletedEvent.parameters.push(
    new ethereum.EventParam("artist", ethereum.Value.fromAddress(artist))
  )
  dropDeletedEvent.parameters.push(
    new ethereum.EventParam("dropId", ethereum.Value.fromUnsignedBigInt(dropId))
  )

  return dropDeletedEvent
}

export function createRemixableEvent(
  collectionId: BigInt,
  remixable: boolean
): Remixable {
  let remixableEvent = changetype<Remixable>(newMockEvent())

  remixableEvent.parameters = new Array()

  remixableEvent.parameters.push(
    new ethereum.EventParam(
      "collectionId",
      ethereum.Value.fromUnsignedBigInt(collectionId)
    )
  )
  remixableEvent.parameters.push(
    new ethereum.EventParam("remixable", ethereum.Value.fromBoolean(remixable))
  )

  return remixableEvent
}
