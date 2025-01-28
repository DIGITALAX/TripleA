import {
  AcceptedTokenRemoved as AcceptedTokenRemovedEvent,
  AcceptedTokenSet as AcceptedTokenSetEvent,
  AdminAdded as AdminAddedEvent,
  AdminRemoved as AdminRemovedEvent,
  AgentAdded as AgentAddedEvent,
  AgentRemoved as AgentRemovedEvent,
  FaucetUsed as FaucetUsedEvent,
  TokenThresholdSet as TokenThresholdSetEvent,
} from "../generated/AAAAccessControls/AAAAccessControls";
import {
  AcceptedTokenRemoved,
  AcceptedTokenSet,
  AdminAdded,
  AdminRemoved,
  AgentAdded,
  AgentRemoved,
  FaucetUsed,
  TokenThresholdSet,
} from "../generated/schema";

export function handleAcceptedTokenRemoved(
  event: AcceptedTokenRemovedEvent
): void {
  let entity = new AcceptedTokenRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAcceptedTokenSet(event: AcceptedTokenSetEvent): void {
  let entity = new AcceptedTokenSet(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAdminAdded(event: AdminAddedEvent): void {
  let entity = new AdminAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.admin = event.params.admin;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAdminRemoved(event: AdminRemovedEvent): void {
  let entity = new AdminRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.admin = event.params.admin;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAgentAdded(event: AgentAddedEvent): void {
  let entity = new AgentAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.agent = event.params.agent;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleAgentRemoved(event: AgentRemovedEvent): void {
  let entity = new AgentRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.agent = event.params.agent;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleFaucetUsed(event: FaucetUsedEvent): void {
  let entity = new FaucetUsed(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.to = event.params.to;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleTokenThresholdSet(event: TokenThresholdSetEvent): void {
  let entity = new TokenThresholdSet(event.params.token);
  entity.token = event.params.token;
  entity.threshold = event.params.threshold;
  entity.rent = event.params.rent;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}
