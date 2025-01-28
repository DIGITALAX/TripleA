import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
  AgentOwnerPaid as AgentOwnerPaidEvent,
  FundsReceived as FundsReceivedEvent,
  OrderPayment as OrderPaymentEvent,
  DevTreasuryAdded as DevTreasuryAddedEvent,
  AgentPaidRent as AgentPaidRentEvent,
  FundsWithdrawnTreasury as FundsWithdrawnTreasuryEvent,
  FundsWithdrawnServices as FundsWithdrawnServicesEvent,
  FundsWithdrawnWithoutReceive as FundsWithdrawnWithoutReceiveEvent,
} from "../generated/AAADevTreasury/AAADevTreasury";
import {
  AgentPaidRent,
  FundsWithdrawnTreasury,
  FundsWithdrawnServices,
  FundsWithdrawnWithoutReceive,
  AgentOwnerPaid,
  DevTreasury,
  DevTreasuryAdded,
  FundsReceived,
  OrderPayment,
} from "../generated/schema";

export function handleAgentOwnerPaid(event: AgentOwnerPaidEvent): void {
  let entity = new AgentOwnerPaid(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.owner = event.params.owner;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let devEntity = DevTreasury.load(event.params.token);

  if (!devEntity) {
    devEntity = new DevTreasury(event.params.token);
    devEntity.id = event.params.token;
  }
  let amount = devEntity.amount;
  if (!amount) {
    amount = BigInt.fromI32(0);
  }
  devEntity.amount = amount.plus(event.params.amount);
  devEntity.token = event.params.token;

  devEntity.save();

  entity.save();
}

export function handleFundsReceived(event: FundsReceivedEvent): void {
  let entity = new FundsReceived(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.buyer = event.params.buyer;
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleOrderPayment(event: OrderPaymentEvent): void {
  let entity = new OrderPayment(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.recipient = event.params.recipient;
  entity.amount = event.params.amount;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleDevTreasuryAdded(event: DevTreasuryAddedEvent): void {
  let entity = new DevTreasuryAdded(event.params.token);
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.save();
}

export function handleAgentPaidRent(event: AgentPaidRentEvent): void {
  let entity = new AgentPaidRent(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.tokens = event.params.tokens.map<Bytes>((target: Bytes) => target);
  entity.amounts = event.params.amounts;
  entity.agentId = event.params.agentId;
  entity.collectionIds = event.params.collectionIds;
  entity.bonuses = event.params.bonuses;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}

export function handleFundsWithdrawnWithoutReceive(
  event: FundsWithdrawnWithoutReceiveEvent
): void {
  let entity = new FundsWithdrawnWithoutReceive(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.save();
}

export function handleFundsWithdrawnServices(
  event: FundsWithdrawnServicesEvent
): void {
  let entity = new FundsWithdrawnServices(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.save();
}

export function handleFundsWithdrawnTreasury(
  event: FundsWithdrawnTreasuryEvent
): void {
  let entity = new FundsWithdrawnTreasury(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;
  entity.amount = event.params.amount;

  entity.save();
}
