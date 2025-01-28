import {
  Address,
  BigInt,
  ByteArray,
  Bytes,
  log,
  store,
} from "@graphprotocol/graph-ts";
import {
  AAACollectionManager,
  CollectionDeleted as CollectionDeletedEvent,
  CollectionCreated as CollectionCreatedEvent,
  DropCreated as DropCreatedEvent,
  DropDeleted as DropDeletedEvent,
  CollectionDeactivated as CollectionDeactivatedEvent,
  CollectionActivated as CollectionActivatedEvent,
  AgentDetailsUpdated as AgentDetailsUpdatedEvent,
  CollectionPriceAdjusted as CollectionPriceAdjustedEvent,
} from "../generated/AAACollectionManager/AAACollectionManager";
import {
  CollectionDeleted,
  CollectionCreated,
  DropCreated,
  DropDeleted,
  CollectionActivated,
  CollectionDeactivated,
  AgentCreated,
  AgentDetails,
  AgentDetailsUpdated,
  CollectionPriceAdjusted,
} from "../generated/schema";
import {
  CollectionMetadata as CollectionMetadataTemplate,
  DropMetadata as DropMetadataTemplate,
} from "../generated/templates";

export function handleCollectionActivated(
  event: CollectionActivatedEvent
): void {
  let entity = new CollectionActivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    entityCollection.active = true;
    entityCollection.save();
  }
}

export function handleCollectionDeactivated(
  event: CollectionDeactivatedEvent
): void {
  let entity = new CollectionDeactivated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;

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

  // drops

  if (entityCollection) {
    let entityDrop = DropCreated.load(
      Bytes.fromByteArray(ByteArray.fromBigInt(entityCollection.dropId))
    );

    if (entityDrop) {
      let updatedCollectionIds: BigInt[] = [];
      let updatedCollections: Bytes[] = [];
      for (let i = 0; i < (entityDrop.collectionIds as BigInt[]).length; i++) {
        if ((entityDrop.collectionIds as BigInt[])[i] !== entity.collectionId) {
          updatedCollectionIds.push((entityDrop.collectionIds as BigInt[])[i]);
        }
      }

      for (let i = 0; i < (entityDrop.collections as Bytes[]).length; i++) {
        if (
          (entityDrop.collections as Bytes[])[i] !==
          Bytes.fromByteArray(ByteArray.fromBigInt(entity.collectionId))
        ) {
          updatedCollections.push((entityDrop.collections as Bytes[])[i]);
        }
      }

      entityDrop.collectionIds = updatedCollectionIds;
      entityDrop.collections = updatedCollections;

      entityDrop.save();
    }

    store.remove(
      "CollectionCreated",
      Bytes.fromByteArray(
        ByteArray.fromBigInt(event.params.collectionId)
      ).toHexString()
    );
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

  let collectionManager = AAACollectionManager.bind(
    Address.fromString("0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1")
  );

  entity.amount = collectionManager.getCollectionAmount(entity.collectionId);
  entity.agents = collectionManager.getCollectionAgentIds(entity.collectionId);
  entity.prices = collectionManager.getCollectionPrices(entity.collectionId);
  entity.tokens = collectionManager
    .getCollectionERC20Tokens(entity.collectionId)
    .map<Bytes>((target: Bytes) => target);
  entity.uri = collectionManager.getCollectionMetadata(entity.collectionId);
  entity.active = true;
  let ipfsHash = (entity.uri as String).split("/").pop();
  if (ipfsHash != null) {
    entity.metadata = ipfsHash;
    CollectionMetadataTemplate.create(ipfsHash);
  }

  for (let i = 0; i < (entity.agents as BigInt[]).length; i++) {
    let current_agent = AgentCreated.load(
      Bytes.fromByteArray(ByteArray.fromBigInt((entity.agents as BigInt[])[i]))
    );

    if (current_agent) {
      let collectionIdHex = entity.collectionId.toHexString();
      let agentHex = (entity.agents as BigInt[])[i].toHexString();
      let agentWalletHex = (current_agent.wallets as Bytes[])[0].toHexString();
      let combinedHex = collectionIdHex + agentHex + agentWalletHex;
      if (combinedHex.length % 2 !== 0) {
        combinedHex = "0" + combinedHex;
      }

      let new_details = current_agent.details;

      if (!new_details) {
        new_details = [];
      }

      let agent_details = AgentDetails.load(Bytes.fromHexString(combinedHex));

      if (!agent_details) {
        agent_details = new AgentDetails(Bytes.fromHexString(combinedHex));

        new_details.push(Bytes.fromHexString(combinedHex));
      }
      agent_details.collectionId = entity.collectionId;
      agent_details.cycleFrequency =
        collectionManager.getAgentCollectionCycleFrequency(
          entity.collectionId,
          (entity.agents as BigInt[])[i]
        );
      agent_details.instructions =
        collectionManager.getAgentCollectionCustomInstructions(
          entity.collectionId,
          (entity.agents as BigInt[])[i]
        );
      agent_details.save();

      if (!new_details.includes(Bytes.fromHexString(combinedHex))) {
        new_details.push(Bytes.fromHexString(combinedHex));
      }

      current_agent.details = new_details;
      current_agent.save();
    }
  }

  entity.prices = collectionManager.getCollectionPrices(entity.collectionId);

  entity.save();

  let entityDrop = DropCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.dropId))
  );

  if (entityDrop) {
    let collectionIds = collectionManager.getDropCollectionIds(entity.dropId);
    let collections = entityDrop.collections;

    if (!collections) {
      collections = [];
    }

    for (let i = 0; i < (collectionIds as BigInt[]).length; i++) {
      let collectionIdAsBytes = Bytes.fromByteArray(
        ByteArray.fromBigInt(collectionIds[i])
      );

      let exists = false;

      for (let j = 0; j < collections.length; j++) {
        if (collections[j] == collectionIdAsBytes) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        collections.push(collectionIdAsBytes);
      }
    }
    entityDrop.collections = collections;
    entityDrop.save();
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

  let collectionManager = AAACollectionManager.bind(
    Address.fromString("0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1")
  );
  let uriResult = collectionManager.try_getDropMetadata(entity.dropId);
  if (uriResult.reverted) {
    log.warning("getDropMetadata reverted for dropId: {}", [
      entity.dropId.toString(),
    ]);
    return;
  }
  entity.uri = uriResult.value;

  if (entity.uri !== null) {
    let ipfsHash = (entity.uri as string).split("/").pop();
    if (ipfsHash != null) {
      entity.metadata = ipfsHash;
      DropMetadataTemplate.create(ipfsHash);
    }
  }

  entity.collectionIds = collectionManager.getDropCollectionIds(entity.dropId);

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
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.artist = event.params.artist;
  entity.dropId = event.params.dropId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let entityDrop = DropCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.dropId))
  );

  if (entityDrop) {
    let collectionIds = entityDrop.collectionIds;

    if (collectionIds) {
      for (let i = 0; i < collectionIds.length; i++) {
        let collectionId = collectionIds[i];

        if (collectionId) {
          let entityCollection = CollectionCreated.load(
            Bytes.fromByteArray(ByteArray.fromBigInt(collectionId))
          );

          if (entityCollection) {
            store.remove(
              "CollectionCreated",
              Bytes.fromByteArray(
                ByteArray.fromBigInt(collectionId)
              ).toHexString()
            );
          }
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

  entity.save();
}

export function handleCollectionPriceAdjusted(
  event: CollectionPriceAdjustedEvent
): void {
  let entity = new CollectionPriceAdjusted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;
  entity.newPrice = event.params.newPrice;
  entity.token = event.params.token;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    let prices = entityCollection.prices;

    if (!prices) {
      prices = [];
    }

    prices[0] = entity.newPrice;

    entityCollection.prices = prices;
    entityCollection.save();
  }
}

export function handleAgentDetailsUpdated(
  event: AgentDetailsUpdatedEvent
): void {
  let entity = new AgentDetailsUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.collectionId = event.params.collectionId;
  entity.customInstructions = event.params.customInstructions;
  entity.cycleFrequency = event.params.cycleFrequency;
  entity.agentIds = event.params.agentIds;

  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    let collectionManager = AAACollectionManager.bind(
      Address.fromString("0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1")
    );
    let agents = entityCollection.agents;
    if (!agents) {
      agents = [];
    }

    for (let i = 0; i < agents.length; i++) {
      let current_agent = AgentCreated.load(
        Bytes.fromByteArray(ByteArray.fromBigInt(agents[i]))
      );

      if (current_agent) {
        let collectionIdHex = entityCollection.collectionId.toHexString();
        let agentHex = agents[i].toHexString();
        let agentWalletHex = (
          current_agent.wallets as Bytes[]
        )[0].toHexString();
        let combinedHex = collectionIdHex + agentHex + agentWalletHex;
        if (combinedHex.length % 2 !== 0) {
          combinedHex = "0" + combinedHex;
        }

        let details = current_agent.details;

        if (!details) {
          details = [];
        }

        let agent_details = AgentDetails.load(Bytes.fromHexString(combinedHex));

        if (!agent_details) {
          agent_details = new AgentDetails(Bytes.fromHexString(combinedHex));
          details.push(Bytes.fromHexString(combinedHex));
        }
        agent_details.collectionId = entity.collectionId;
        agent_details.cycleFrequency =
          collectionManager.getAgentCollectionCycleFrequency(
            entity.collectionId,
            agents[i]
          );
        agent_details.instructions =
          collectionManager.getAgentCollectionCustomInstructions(
            entity.collectionId,
            agents[i]
          );
        agent_details.save();

        current_agent.details = details;
        current_agent.save();
      }
    }
  }
}
