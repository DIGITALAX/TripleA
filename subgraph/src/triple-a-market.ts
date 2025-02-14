import { Address, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  CollectionPurchased as CollectionPurchasedEvent,
  FulfillmentUpdated as FulfillmentUpdatedEvent,
  TripleAMarket,
} from "../generated/TripleAMarket/TripleAMarket";
import {
  CollectionCreated,
  CollectionPurchased,
  FulfillmentUpdated,
} from "../generated/schema";
import { TripleACollectionManager } from "../generated/TripleACollectionManager/TripleACollectionManager";

export function handleCollectionPurchased(
  event: CollectionPurchasedEvent
): void {
  let entity = new CollectionPurchased(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.orderId))
  );
  entity.buyer = event.params.buyer;
  entity.paymentToken = event.params.paymentToken;
  entity.orderId = event.params.orderId;
  entity.collectionId = event.params.collectionId;
  entity.amount = event.params.amount;
  entity.artistShare = event.params.artistShare;
  entity.fulfillerShare = event.params.fulfillerShare;
  entity.agentShare = event.params.agentShare;
  entity.remixShare = event.params.remixShare;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  let market = TripleAMarket.bind(event.address);

  let collectionManager = TripleACollectionManager.bind(
    Address.fromString("0x6B434299F649eE8A908A67eeeAE4BE1E57720788")
  );
  entity.mintedTokens = market.getOrderMintedTokens(event.params.orderId);
  entity.totalPrice = market.getOrderTotalPrice(event.params.orderId);
  entity.collection = Bytes.fromByteArray(
    ByteArray.fromBigInt(event.params.collectionId)
  );
  entity.fulfillment = market.getOrderFulfillmentDetails(event.params.orderId);
  entity.fulfiller = collectionManager.getCollectionFulfillerId(event.params.collectionId);
  entity.save();


  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    entityCollection.tokenIds = collectionManager.getCollectionTokenIds(
      event.params.collectionId
    );
    entityCollection.amountSold = collectionManager.getCollectionAmountSold(
      event.params.collectionId
    );

    entityCollection.save();
  }
}

export function handleFulfillmentUpdated(event: FulfillmentUpdatedEvent): void {
  let entity = new FulfillmentUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.fulfillment = event.params.fulfillment;
  entity.orderId = event.params.orderId;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let orderEntity = new CollectionPurchased(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.orderId))
  );

  if (orderEntity) {
    orderEntity.fulfillment = event.params.fulfillment;
    orderEntity.save();
  }
}
