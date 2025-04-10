import {
  AddAgentWallet as AddAgentWalletEvent,
  AddOwner as AddOwnerEvent,
  AgentCreated as AgentCreatedEvent,
  AgentDeleted as AgentDeletedEvent,
  AgentEdited as AgentEditedEvent,
  AgentScored as AgentScoredEvent,
  AgentSetActive as AgentSetActiveEvent,
  AgentSetInactive as AgentSetInactiveEvent,
  RevokeAgentWallet as RevokeAgentWalletEvent,
  RevokeOwner as RevokeOwnerEvent,
  SkyhuntersAgentManager,
} from "../generated/SkyhuntersAgentManager/SkyhuntersAgentManager";
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
  RevokeOwner,
} from "../generated/schema";
import { ByteArray, Bytes, store } from "@graphprotocol/graph-ts";
import { AgentMetadata } from "../generated/templates";

export function handleAddAgentWallet(event: AddAgentWalletEvent): void {
  let entity = new AddAgentWallet(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.wallets = agents
      .getAgentWallets(event.params.agentId)
      .map<Bytes>((target: Bytes) => target);
    entityAgent.save();
  }
}

export function handleAddOwner(event: AddOwnerEvent): void {
  let entity = new AddOwner(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.owners = agents
      .getAgentOwners(event.params.agentId)
      .map<Bytes>((target: Bytes) => target);
    entityAgent.save();
  }
}

export function handleAgentCreated(event: AgentCreatedEvent): void {
  let entity = new AgentCreated(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.id))
  );
  entity.wallets = event.params.wallets.map<Bytes>((target: Bytes) => target);
  entity.creator = event.params.creator;
  entity.SkyhuntersAgentManager_id = event.params.id;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let agents = SkyhuntersAgentManager.bind(event.address);
  entity.owners = agents
    .getAgentOwners(event.params.id)
    .map<Bytes>((target: Bytes) => target);
  entity.uri = agents.getAgentMetadata(event.params.id);

  entity.skyhunter = agents.getAgentSkyhunter(event.params.id);
  entity.studio = agents.getAgentStudio(event.params.id);

  let ipfsHash = (entity.uri as String).split("/").pop();
  if (ipfsHash != null) {
    entity.metadata = ipfsHash;
    AgentMetadata.create(ipfsHash);
  }

  entity.save();
}

export function handleAgentDeleted(event: AgentDeletedEvent): void {
  let entity = new AgentDeleted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.SkyhuntersAgentManager_id = event.params.id;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.id))
  );

  if (entityAgent) {
    store.remove(
      "AgentCreated",
      Bytes.fromByteArray(ByteArray.fromBigInt(event.params.id)).toHexString()
    );
  }
}

export function handleAgentEdited(event: AgentEditedEvent): void {
  let entity = new AgentEdited(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.SkyhuntersAgentManager_id = event.params.id;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.id))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.uri = agents.getAgentMetadata(event.params.id);

    let ipfsHash = (entityAgent.uri as String).split("/").pop();
    if (ipfsHash != null) {
      entityAgent.metadata = ipfsHash;
      AgentMetadata.create(ipfsHash);
    }

    entityAgent.save();
  }
}

export function handleAgentScored(event: AgentScoredEvent): void {
  let entity = new AgentScored(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.scorer = event.params.scorer;
  entity.agentId = event.params.agentId;
  entity.score = event.params.score;
  entity.positive = event.params.positive;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.scorePositive = agents.getAgentScorePositive(
      event.params.agentId
    );
    entityAgent.scoreNegative = agents.getAgentScoreNegative(
      event.params.agentId
    );

    entityAgent.save();
  }
}

export function handleAgentSetActive(event: AgentSetActiveEvent): void {
  let entity = new AgentSetActive(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  // let entityAgent = AgentCreated.load(
  //   Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  // );

  // if (entityAgent) {
  //   let agents = SkyhuntersAgentManager.bind(event.address);
  //   entityAgent.active = agents.getAgentActive(event.params.agentId);
  //   entityAgent.save();
  // }
}

export function handleAgentSetInactive(event: AgentSetInactiveEvent): void {
  let entity = new AgentSetInactive(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  // let entityAgent = AgentCreated.load(
  //   Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  // );

  // if (entityAgent) {
  //   let agents = SkyhuntersAgentManager.bind(event.address);
  //   entityAgent.active = agents.getAgentActive(event.params.agentId);

  //   entityAgent.save();
  // }
}

export function handleRevokeAgentWallet(event: RevokeAgentWalletEvent): void {
  let entity = new RevokeAgentWallet(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.wallets = agents
      .getAgentWallets(event.params.agentId)
      .map<Bytes>((target: Bytes) => target);
    entityAgent.save();
  }
}

export function handleRevokeOwner(event: RevokeOwnerEvent): void {
  let entity = new RevokeOwner(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let agents = SkyhuntersAgentManager.bind(event.address);

    entityAgent.owners = agents
      .getAgentOwners(event.params.agentId)
      .map<Bytes>((target: Bytes) => target);
    entityAgent.save();
  }
}
