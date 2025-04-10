import {
  AgentDetailsUpdated as AgentDetailsUpdatedEvent,
  CollectionActivated as CollectionActivatedEvent,
  CollectionCreated as CollectionCreatedEvent,
  CollectionDeactivated as CollectionDeactivatedEvent,
  CollectionDeleted as CollectionDeletedEvent,
  CollectionDropUpdated as CollectionDropUpdatedEvent,
  CollectionPriceAdjusted as CollectionPriceAdjustedEvent,
  DropCreated as DropCreatedEvent,
  DropDeleted as DropDeletedEvent,
  Remixable as RemixableEvent
} from "../generated/TripleACollectionManager/TripleACollectionManager"
import {
  AgentDetailsUpdated,
  CollectionActivated,
  CollectionCreated,
  CollectionDeactivated,
  CollectionDeleted,
  CollectionDropUpdated,
  CollectionPriceAdjusted,
  DropCreated,
  DropDeleted,
  Remixable
} from "../generated/schema"

export function handleAgentDetailsUpdated(
  event: AgentDetailsUpdatedEvent
): void {
  let entity = new AgentDetailsUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.customInstructions = event.params.customInstructions
  entity.agentIds = event.params.agentIds
  entity.collectionId = event.params.collectionId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionActivated(
  event: CollectionActivatedEvent
): void {
  let entity = new CollectionActivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.collectionId = event.params.collectionId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionCreated(event: CollectionCreatedEvent): void {
  let entity = new CollectionCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.artist = event.params.artist
  entity.collectionId = event.params.collectionId
  entity.dropId = event.params.dropId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionDeactivated(
  event: CollectionDeactivatedEvent
): void {
  let entity = new CollectionDeactivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.collectionId = event.params.collectionId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionDeleted(event: CollectionDeletedEvent): void {
  let entity = new CollectionDeleted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.collectionId = event.params.collectionId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionDropUpdated(
  event: CollectionDropUpdatedEvent
): void {
  let entity = new CollectionDropUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.collectionId = event.params.collectionId
  entity.dropId = event.params.dropId
  entity.agentId = event.params.agentId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleCollectionPriceAdjusted(
  event: CollectionPriceAdjustedEvent
): void {
  let entity = new CollectionPriceAdjusted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.token = event.params.token
  entity.collectionId = event.params.collectionId
  entity.newPrice = event.params.newPrice

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleDropCreated(event: DropCreatedEvent): void {
  let entity = new DropCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.artist = event.params.artist
  entity.dropId = event.params.dropId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleDropDeleted(event: DropDeletedEvent): void {
  let entity = new DropDeleted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.dropId = event.params.dropId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRemixable(event: RemixableEvent): void {
  let entity = new Remixable(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.sender = event.params.sender
  entity.collectionId = event.params.collectionId
  entity.remixable = event.params.remixable

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
