import {
  Address,
  BigInt,
  ByteArray,
  Bytes,
  store,
} from "@graphprotocol/graph-ts";
import {
  AgentDetailsUpdated as AgentDetailsUpdatedEvent,
  CollectionActivated as CollectionActivatedEvent,
  CollectionCreated as CollectionCreatedEvent,
  CollectionDeactivated as CollectionDeactivatedEvent,
  CollectionDeleted as CollectionDeletedEvent,
  CollectionPriceAdjusted as CollectionPriceAdjustedEvent,
  DropCreated as DropCreatedEvent,
  DropDeleted as DropDeletedEvent,
  Remixable as RemixableEvent,
  TripleACollectionManager,
} from "../generated/TripleACollectionManager/TripleACollectionManager";
import {
  AgentCreated,
  AgentDetailsUpdated,
  CollectionActivated,
  CollectionCreated,
  CollectionDeactivated,
  CollectionDeleted,
  CollectionPriceAdjusted,
  DropCreated,
  DropDeleted,
  Price,
  Remixable,
} from "../generated/schema";
import { CollectionMetadata, DropMetadata } from "../generated/templates";
import { TripleAAgents } from "../generated/TripleAAgents/TripleAAgents";

export function handleAgentDetailsUpdated(
  event: AgentDetailsUpdatedEvent
): void {
  let entity = new AgentDetailsUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.customInstructions = event.params.customInstructions;
  entity.agentIds = event.params.agentIds;
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleCollectionActivated(
  event: CollectionActivatedEvent
): void {
  let entity = new CollectionActivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    entityCollection.active = true;

    entityCollection.save();
  }
}

export function handleCollectionCreated(event: CollectionCreatedEvent): void {
  let entity = new CollectionCreated(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );
  entity.artist = event.params.artist;
  entity.collectionId = event.params.collectionId;
  entity.dropId = event.params.dropId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let collectionManager = TripleACollectionManager.bind(event.address);
  let agents = TripleAAgents.bind(
    Address.fromString("0x0c66DF3847Eae30797a62C2d2C28cf30B7af01Ce")
  );

  entity.amount = collectionManager.getCollectionAmount(entity.collectionId);
  entity.agentIds = collectionManager.getCollectionAgentIds(
    entity.collectionId
  );

  let customInstructions: string[] = [];
  for (let i = 0; i < (entity.agentIds as BigInt[]).length; i++) {
    let instructions = agents.try_getWorkerInstructions(
      (entity.agentIds as BigInt[])[i],
      event.params.collectionId
    );

    if (!instructions.reverted) {
      customInstructions.push(instructions.value);
    }
  }
  entity.active = true;
  entity.uri = collectionManager.getCollectionMetadata(entity.collectionId);
  let ipfsHash = (entity.uri as String).split("/").pop();
  if (ipfsHash != null) {
    entity.metadata = ipfsHash;
    CollectionMetadata.create(ipfsHash);
  }

  let prices: Bytes[] = [];

  let tokens: Address[] = collectionManager.getCollectionERC20Tokens(
    entity.collectionId
  );

  for (let i = 0; i < (tokens as Address[]).length; i++) {
    let price = collectionManager.getCollectionTokenPrice(
      (tokens as Address[])[i],
      entity.collectionId
    );

    let tokenHex = (tokens as Address[])[i].toHexString();
    let priceHex = price.toHexString();
    let combinedHex = tokenHex + priceHex;
    if (combinedHex.length % 2 !== 0) {
      combinedHex = "0" + combinedHex;
    }

    let entityPrice = new Price(Bytes.fromHexString(combinedHex));
    entityPrice.token = (tokens as Address[])[i];
    entityPrice.price = price;
    entityPrice.save();

    prices.push(Bytes.fromHexString(combinedHex));
  }

  entity.prices = prices;

  entity.fulfillerId = collectionManager.getCollectionFulfillerId(
    entity.collectionId
  );
  entity.remixable = collectionManager.getCollectionIsRemixable(
    entity.collectionId
  );
  entity.remixId = collectionManager.getCollectionRemixId(entity.collectionId);
  entity.isAgent = collectionManager.getCollectionIsByAgent(
    entity.collectionId
  );
  entity.remixCollection = Bytes.fromByteArray(
    ByteArray.fromBigInt(entity.remixId as BigInt)
  );
  entity.collectionType = BigInt.fromI32(
    collectionManager.getCollectionType(entity.collectionId)
  );

  entity.dropUri = collectionManager.getDropMetadata(entity.dropId);
  let ipfsHashDrop = (entity.dropUri as String).split("/").pop();
  if (ipfsHashDrop != null) {
    entity.drop = ipfsHashDrop;
    DropMetadata.create(ipfsHashDrop);
  }

  entity.save();
}

export function handleCollectionDeactivated(
  event: CollectionDeactivatedEvent
): void {
  let entity = new CollectionDeactivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    entityCollection.active = false;

    entityCollection.save();
  }
}

export function handleCollectionDeleted(event: CollectionDeletedEvent): void {
  let entity = new CollectionDeleted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.artist = event.params.artist;
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    let agents = entityCollection.agentIds;

    if (agents) {
      for (let i = 0; i < (agents as BigInt[]).length; i++) {
        let entityAgent = AgentCreated.load(
          Bytes.fromByteArray(ByteArray.fromBigInt((agents as BigInt[])[i]))
        );

        if (entityAgent) {
          let workers = entityAgent.workers;
          if (workers) {
            for (let j = 0; j < (workers as Bytes[]).length; j++) {
              store.remove(
                "CollectionWorker",
                (workers as Bytes[])[j].toHexString()
              );
            }
          }
        }
      }
    }

    store.remove(
      "CollectionCreated",
      Bytes.fromByteArray(
        ByteArray.fromBigInt(event.params.collectionId)
      ).toHexString()
    );
  }
}

export function handleCollectionPriceAdjusted(
  event: CollectionPriceAdjustedEvent
): void {
  let entity = new CollectionPriceAdjusted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.collectionId = event.params.collectionId;
  entity.newPrice = event.params.newPrice;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  let collectionManager = TripleACollectionManager.bind(event.address);

  if (entityCollection) {
    let prices: Bytes[] = [];

    let tokens: Address[] = collectionManager.getCollectionERC20Tokens(
      entity.collectionId
    );
    for (let i = 0; i < (tokens as Address[]).length; i++) {
      let price = collectionManager.getCollectionTokenPrice(
        (tokens as Address[])[i],
        entity.collectionId
      );

      let tokenHex = (tokens as Address[])[i].toHexString();
      let priceHex = price.toHexString();
      let combinedHex = tokenHex + priceHex;
      if (combinedHex.length % 2 !== 0) {
        combinedHex = "0" + combinedHex;
      }

      let entityPrice = new Price(Bytes.fromHexString(combinedHex));
      entityPrice.token = (tokens as Address[])[i];
      entityPrice.price = price;
      entityPrice.save();

      prices.push(Bytes.fromHexString(combinedHex));
    }

    entityCollection.prices = prices;

    entityCollection.save();
  }
}

export function handleDropCreated(event: DropCreatedEvent): void {
  let entity = new DropCreated(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.dropId))
  );
  entity.artist = event.params.artist;
  entity.dropId = event.params.dropId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let collectionManager = TripleACollectionManager.bind(event.address);

  entity.collectionIds = collectionManager.getDropCollectionIds(entity.dropId);
  entity.uri = collectionManager.getDropMetadata(entity.dropId);
  let ipfsHashDrop = (entity.uri as String).split("/").pop();
  if (ipfsHashDrop != null) {
    entity.metadata = ipfsHashDrop;
    DropMetadata.create(ipfsHashDrop);
  }

  let collections: Bytes[] = [];
  for (let i = 0; i < (entity.collectionIds as BigInt[]).length; i++) {
    collections.push(
      Bytes.fromByteArray(
        ByteArray.fromBigInt((entity.collectionIds as BigInt[])[i])
      )
    );
  }
  entity.collections = collections;

  entity.save();
}

export function handleDropDeleted(event: DropDeletedEvent): void {
  let entity = new DropDeleted(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.dropId))
  );
  entity.artist = event.params.artist;
  entity.dropId = event.params.dropId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityDrop = DropCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.dropId))
  );

  if (entityDrop) {
    if (entityDrop.collections) {
      for (let i = 0; i < (entityDrop.collections as Bytes[]).length; i++) {
        let entityCollection = CollectionCreated.load(
          (entityDrop.collections as Bytes[])[i]
        );

        if (entityCollection) {

          let agents = entityCollection.agentIds;

          if (agents) {
            for (let i = 0; i < (agents as BigInt[]).length; i++) {
              let entityAgent = AgentCreated.load(
                Bytes.fromByteArray(ByteArray.fromBigInt((agents as BigInt[])[i]))
              );
      
              if (entityAgent) {
                let workers = entityAgent.workers;
                if (workers) {
                  for (let j = 0; j < (workers as Bytes[]).length; j++) {
                    store.remove(
                      "CollectionWorker",
                      (workers as Bytes[])[j].toHexString()
                    );
                  }
                }
              }
            }
          }
          
          store.remove(
            "CollectionCreated",
            (entityDrop.collections as Bytes[])[i].toHexString()
          );
        }
      }
    }

    store.remove(
      "DropCreated",
      Bytes.fromByteArray(
        ByteArray.fromBigInt(event.params.dropId)
      ).toHexString()
    );
  }
}

export function handleRemixable(event: RemixableEvent): void {
  let entity = new Remixable(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;
  entity.remixable = event.params.remixable;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    entityCollection.remixable = entity.remixable;

    entityCollection.save();
  }
}
