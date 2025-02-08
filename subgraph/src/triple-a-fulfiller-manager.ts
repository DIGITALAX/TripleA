import { Address, ByteArray, Bytes, store } from "@graphprotocol/graph-ts";
import {
  FulfillerCreated as FulfillerCreatedEvent,
  FulfillerDeleted as FulfillerDeletedEvent,
  OrderAdded as OrderAddedEvent,
  OrderFulfilled as OrderFulfilledEvent,
  TripleAFulfillerManager,
} from "../generated/TripleAFulfillerManager/TripleAFulfillerManager";
import {
  CollectionPurchased,
  FulfillerCreated,
  FulfillerDeleted,
  OrderAdded,
  OrderFulfilled,
} from "../generated/schema";
import { FulfillerMetadata } from "../generated/templates";

export function handleFulfillerCreated(event: FulfillerCreatedEvent): void {
  let entity = new FulfillerCreated(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.fulfillerId))
  );
  entity.wallet = event.params.wallet;
  entity.fulfillerId = event.params.fulfillerId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let fulfillerManager = TripleAFulfillerManager.bind(event.address);

  entity.uri = fulfillerManager.getFulfillerMetadata(event.params.fulfillerId);
  let ipfsHash = (entity.uri as String).split("/").pop();
  if (ipfsHash != null) {
    entity.metadata = ipfsHash;
    FulfillerMetadata.create(ipfsHash);
  }

  entity.save();
}

export function handleFulfillerDeleted(event: FulfillerDeletedEvent): void {
  let entity = new FulfillerDeleted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.fulfillerId = event.params.fulfillerId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityFulfiller = FulfillerCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.fulfillerId))
  );

  if (entityFulfiller) {
    store.remove(
      "FulfillerCreated",
      Bytes.fromByteArray(
        ByteArray.fromBigInt(event.params.fulfillerId)
      ).toHexString()
    );
  }
}

export function handleOrderAdded(event: OrderAddedEvent): void {
  let entity = new OrderAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.fulfillerId = event.params.fulfillerId;
  entity.orderId = event.params.orderId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityFulfiller = FulfillerCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.fulfillerId))
  );
  let fulfillerManager = TripleAFulfillerManager.bind(event.address);

  if (entityFulfiller) {
    entityFulfiller.activeOrders = fulfillerManager.getFulfillerActiveOrders(
      event.params.fulfillerId
    );
    entityFulfiller.orderHistory = fulfillerManager.getFulfillerOrderHistory(
      event.params.fulfillerId
    );

    entityFulfiller.save();
  }
}

export function handleOrderFulfilled(event: OrderFulfilledEvent): void {
  let entity = new OrderFulfilled(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.fulfillerId = event.params.fulfillerId;
  entity.orderId = event.params.orderId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let entityOrder = CollectionPurchased.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.orderId))
  );

  if (entityOrder) {
    entityOrder.fulfilled = true;

    entityOrder.save();
  }
}
