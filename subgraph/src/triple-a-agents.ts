import { Address, BigInt, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  ActivateAgent as ActivateAgentEvent,
  AgentPaidRent as AgentPaidRentEvent,
  AgentRecharged as AgentRechargedEvent,
  BalanceAdded as BalanceAddedEvent,
  RewardsCalculated as RewardsCalculatedEvent,
  TripleAAgents,
  WorkerAdded as WorkerAddedEvent,
  WorkerUpdated as WorkerUpdatedEvent,
} from "../generated/TripleAAgents/TripleAAgents";
import {
  ActivateAgent,
  AgentCreated,
  AgentPaidRent,
  AgentRecharged,
  Balance,
  BalanceAdded,
  CollectionWorker,
  RewardsCalculated,
  WorkerAdded,
  WorkerUpdated,
} from "../generated/schema";
import { TripleACollectionManager } from "../generated/TripleACollectionManager/TripleACollectionManager";

export function handleActivateAgent(event: ActivateAgentEvent): void {
  let entity = new ActivateAgent(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.wallet = event.params.wallet;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAgentPaidRent(event: AgentPaidRentEvent): void {
  let entity = new AgentPaidRent(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.tokens = event.params.tokens.map<Bytes>((target: Bytes) => target);
  entity.collectionIds = event.params.collectionIds;
  entity.amounts = event.params.amounts;
  entity.bonuses = event.params.bonuses;
  entity.agentId = event.params.agentId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(entity.agentId))
  );

  if (entityAgent) {
    let agents = TripleAAgents.bind(event.address);
    let balances = entityAgent.balances;

    if (!balances) {
      balances = [];
    }

    for (let i = 0; i < (entity.collectionIds as BigInt[]).length; i++) {
      let collectionIdHex = (entity.collectionIds as BigInt[])[i].toHexString();
      let tokenHex = (entity.tokens as Bytes[])[i].toHexString();
      let agentHex = entity.agentId.toHexString();
      let agentWalletHex = (entityAgent.wallets as Bytes[])[0].toHexString();
      let combinedHex = collectionIdHex + tokenHex + agentHex + agentWalletHex;
      if (combinedHex.length % 2 !== 0) {
        combinedHex = "0" + combinedHex;
      }

      let newBalance = Balance.load(Bytes.fromHexString(combinedHex));
      if (!newBalance) {
        newBalance = new Balance(Bytes.fromHexString(combinedHex));
        newBalance.collectionId = (entity.collectionIds as BigInt[])[i];
        newBalance.token = (entity.tokens as Bytes[])[i];
        balances.push(Bytes.fromHexString(combinedHex));
      }

      newBalance.rentBalance = agents.getAgentRentBalance(
        (entity.tokens as Bytes[])[i] as Address,
        entity.agentId,
        (entity.collectionIds as BigInt[])[i]
      );
      newBalance.historicalRentBalance = agents.getAgentHistoricalRentBalance(
        (entity.tokens as Bytes[])[i] as Address,
        entity.agentId,
        (entity.collectionIds as BigInt[])[i]
      );
      newBalance.bonusBalance = agents.getAgentBonusBalance(
        (entity.tokens as Bytes[])[i] as Address,
        entity.agentId,
        (entity.collectionIds as BigInt[])[i]
      );
      newBalance.historicalBonusBalance = agents.getAgentHistoricalBonusBalance(
        (entity.tokens as Bytes[])[i] as Address,
        entity.agentId,
        (entity.collectionIds as BigInt[])[i]
      );

      let workerHex = collectionIdHex + agentHex;
      if (workerHex.length % 2 !== 0) {
        workerHex = "0" + workerHex;
      }

      newBalance.worker = Bytes.fromByteArray(
        ByteArray.fromHexString(workerHex)
      );
      newBalance.collection = Bytes.fromByteArray(
        ByteArray.fromBigInt((entity.collectionIds as BigInt[])[i])
      );
      newBalance.save();
    }
    entityAgent.balances = balances;
    entityAgent.activeCollectionIds = agents.getAgentActiveCollectionIds(
      entity.agentId
    );
    entityAgent.collectionIdsHistory = agents.getAgentCollectionIdsHistory(
      entity.agentId
    );
    entityAgent.save();
  }
}

export function handleAgentRecharged(event: AgentRechargedEvent): void {
  let entity = new AgentRecharged(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.recharger = event.params.recharger;
  entity.token = event.params.token;
  entity.agentId = event.params.agentId;
  entity.collectionId = event.params.collectionId;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(entity.agentId))
  );

  if (entityAgent) {
    let agents = TripleAAgents.bind(event.address);
    let collections = TripleACollectionManager.bind(
      Address.fromString("0x575da586767F54DC9ba7E08024844ce72480e234")
    );

    let collectionIdHex = entity.collectionId.toHexString();
    let tokenHex = entity.token.toHexString();
    let agentHex = entity.agentId.toHexString();
    let agentWalletHex = (entityAgent.wallets as Bytes[])[0].toHexString();
    let combinedHex = collectionIdHex + tokenHex + agentHex + agentWalletHex;
    if (combinedHex.length % 2 !== 0) {
      combinedHex = "0" + combinedHex;
    }

    let balances = entityAgent.balances;

    if (!balances) {
      balances = [];
    }

    let newBalance = Balance.load(Bytes.fromHexString(combinedHex));
    if (!newBalance) {
      newBalance = new Balance(Bytes.fromHexString(combinedHex));
      newBalance.collectionId = entity.collectionId;
      newBalance.token = entity.token;
      balances.push(Bytes.fromHexString(combinedHex));
    }

    newBalance.rentBalance = agents.getAgentRentBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.historicalRentBalance = agents.getAgentHistoricalRentBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.bonusBalance = agents.getAgentBonusBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.historicalBonusBalance = agents.getAgentHistoricalBonusBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );

    let workerHex = collectionIdHex + agentHex;
    if (workerHex.length % 2 !== 0) {
      workerHex = "0" + workerHex;
    }

    newBalance.worker = Bytes.fromByteArray(ByteArray.fromHexString(workerHex));
    newBalance.collection = Bytes.fromByteArray(
      ByteArray.fromBigInt(event.params.collectionId)
    );

    newBalance.save();

    entityAgent.balances = balances;

    entityAgent.activeCollectionIds = agents.getAgentActiveCollectionIds(
      entity.agentId
    );
    entityAgent.collectionIdsHistory = agents.getAgentCollectionIdsHistory(
      entity.agentId
    );
    entityAgent.save();
  }
}

export function handleBalanceAdded(event: BalanceAddedEvent): void {
  let entity = new BalanceAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.agentId = event.params.agentId;
  entity.amount = event.params.amount;
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(entity.agentId))
  );

  if (entityAgent) {
    let agents = TripleAAgents.bind(event.address);
    let collections = TripleACollectionManager.bind(
      Address.fromString("0x575da586767F54DC9ba7E08024844ce72480e234")
    );

    let collectionIdHex = entity.collectionId.toHexString();
    let tokenHex = entity.token.toHexString();
    let agentHex = entity.agentId.toHexString();
    let agentWalletHex = (entityAgent.wallets as Bytes[])[0].toHexString();
    let combinedHex = collectionIdHex + tokenHex + agentHex + agentWalletHex;
    if (combinedHex.length % 2 !== 0) {
      combinedHex = "0" + combinedHex;
    }

    let balances = entityAgent.balances;

    if (!balances) {
      balances = [];
    }

    let newBalance = Balance.load(Bytes.fromHexString(combinedHex));
    if (!newBalance) {
      newBalance = new Balance(Bytes.fromHexString(combinedHex));
      newBalance.collectionId = entity.collectionId;
      newBalance.token = entity.token;
      balances.push(Bytes.fromHexString(combinedHex));
    }

    newBalance.rentBalance = agents.getAgentRentBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.historicalRentBalance = agents.getAgentHistoricalRentBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.bonusBalance = agents.getAgentBonusBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );
    newBalance.historicalBonusBalance = agents.getAgentHistoricalBonusBalance(
      event.params.token,
      entity.agentId,
      entity.collectionId
    );

    let workerHex = collectionIdHex + agentHex;
    if (workerHex.length % 2 !== 0) {
      workerHex = "0" + workerHex;
    }

    newBalance.worker = Bytes.fromByteArray(ByteArray.fromHexString(workerHex));
    newBalance.collection = Bytes.fromByteArray(
      ByteArray.fromBigInt(event.params.collectionId)
    );

    newBalance.save();

    entityAgent.balances = balances;

    entityAgent.activeCollectionIds = agents.getAgentActiveCollectionIds(
      entity.agentId
    );
    entityAgent.collectionIdsHistory = agents.getAgentCollectionIdsHistory(
      entity.agentId
    );
    entityAgent.save();
  }
}

export function handleRewardsCalculated(event: RewardsCalculatedEvent): void {
  let entity = new RewardsCalculated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleWorkerAdded(event: WorkerAddedEvent): void {
  let entity = new WorkerAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.agentId = event.params.agentId;
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let workers = entityAgent.workers;
    if (!workers) {
      workers = [];
    }

    let agents = TripleAAgents.bind(event.address);

    let collectionIdHex = event.params.agentId.toHexString();
    let agentHex = event.params.collectionId.toHexString();
    let combinedHex = collectionIdHex + agentHex;
    if (combinedHex.length % 2 !== 0) {
      combinedHex = "0" + combinedHex;
    }

    let newWorker = new CollectionWorker(
      Bytes.fromByteArray(ByteArray.fromHexString(combinedHex))
    );
    newWorker.instructions = agents.getWorkerInstructions(
      event.params.agentId,
      event.params.collectionId
    );
    let collectionManager = TripleACollectionManager.bind(
      Address.fromString("0x575da586767F54DC9ba7E08024844ce72480e234")
    );
    newWorker.tokens = collectionManager
      .getCollectionERC20Tokens(event.params.collectionId)
      .map<Bytes>((target: Bytes) => target);
    newWorker.collectionId = event.params.collectionId;

    newWorker.publish = agents.getWorkerPublish(
      event.params.agentId,
      event.params.collectionId
    );
    newWorker.lead = agents.getWorkerLead(
      event.params.agentId,
      event.params.collectionId
    );
    newWorker.remix = agents.getWorkerRemix(
      event.params.agentId,
      event.params.collectionId
    );
    newWorker.publishFrequency = agents.getWorkerPublishFrequency(
      event.params.agentId,
      event.params.collectionId
    );
    newWorker.leadFrequency = agents.getWorkerLeadFrequency(
      event.params.agentId,
      event.params.collectionId
    );
    newWorker.remixFrequency = agents.getWorkerRemixFrequency(
      event.params.agentId,
      event.params.collectionId
    );

    newWorker.save();

    workers.push(newWorker.id);

    entityAgent.workers = workers;

    entityAgent.save();
  }
}

export function handleWorkerUpdated(event: WorkerUpdatedEvent): void {
  let entity = new WorkerUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.agentId = event.params.agentId;
  entity.collectionId = event.params.collectionId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityAgent = AgentCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.agentId))
  );

  if (entityAgent) {
    let workers = entityAgent.workers;
    if (!workers) {
      workers = [];
    }

    let agents = TripleAAgents.bind(event.address);

    let collectionIdHex = event.params.agentId.toHexString();
    let agentHex = event.params.collectionId.toHexString();
    let combinedHex = collectionIdHex + agentHex;
    if (combinedHex.length % 2 !== 0) {
      combinedHex = "0" + combinedHex;
    }

    let newWorker = CollectionWorker.load(
      Bytes.fromByteArray(ByteArray.fromHexString(combinedHex))
    );

    if (newWorker) {
      let collectionManager = TripleACollectionManager.bind(
        Address.fromString("0x575da586767F54DC9ba7E08024844ce72480e234")
      );
      newWorker.instructions = agents.getWorkerInstructions(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.tokens = collectionManager
        .getCollectionERC20Tokens(event.params.collectionId)
        .map<Bytes>((target: Bytes) => target);
      newWorker.collectionId = event.params.collectionId;

      newWorker.publish = agents.getWorkerPublish(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.lead = agents.getWorkerLead(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.remix = agents.getWorkerRemix(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.publishFrequency = agents.getWorkerPublishFrequency(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.leadFrequency = agents.getWorkerLeadFrequency(
        event.params.agentId,
        event.params.collectionId
      );
      newWorker.remixFrequency = agents.getWorkerRemixFrequency(
        event.params.agentId,
        event.params.collectionId
      );

      newWorker.save();
    }
  }
}
