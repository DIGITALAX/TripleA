import { Address, ByteArray, Bytes } from "@graphprotocol/graph-ts";
import {
  CollectionPurchased as CollectionPurchasedEvent,
  FulfillmentUpdated as FulfillmentUpdatedEvent,
  TripleAMarket,
} from "../generated/TripleAMarket/TripleAMarket";
import {
  CollectionCreated,
  CollectionPrice,
  CollectionPurchased,
  FulfillmentUpdated,
  Price,
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
    Address.fromString("0xAFA95137afe705526bc3afb17D1AAdf554d07160")
  );
  entity.mintedTokens = market.getOrderMintedTokens(event.params.orderId);
  entity.totalPrice = market.getOrderTotalPrice(event.params.orderId);
  entity.collection = Bytes.fromByteArray(
    ByteArray.fromBigInt(event.params.collectionId)
  );
  entity.fulfillment = market.getOrderFulfillmentDetails(event.params.orderId);
  entity.fulfiller = collectionManager.getCollectionFulfillerId(
    event.params.collectionId
  );
  entity.save();

  let entityCollection = CollectionCreated.load(
    Bytes.fromByteArray(ByteArray.fromBigInt(event.params.collectionId))
  );

  if (entityCollection) {
    let sold = collectionManager.getCollectionAmountSold(
      event.params.collectionId
    );

    entityCollection.tokenIds = collectionManager.getCollectionTokenIds(
      event.params.collectionId
    );
    entityCollection.amountSold = sold;

    entityCollection.save();

    for (let i = 0; i < (entityCollection.prices as Bytes[]).length; i++) {
      let price = Price.load((entityCollection.prices as Bytes[])[i]);

      if (price) {
        let tokenHex = (price.token as Bytes).toHexString();
        let collectionHex = entity.collectionId.toHexString();
        let combinedPriceHex = tokenHex + collectionHex;
        if (combinedPriceHex.length % 2 !== 0) {
          combinedPriceHex = "0" + combinedPriceHex;
        }

        let collectionPrice = CollectionPrice.load(
          Bytes.fromByteArray(ByteArray.fromUTF8(combinedPriceHex))
        );

        if (collectionPrice) {
          collectionPrice.amountSold = sold;

          if ((sold = entityCollection.amount)) {
            collectionPrice.soldOut = true;
          }

          collectionPrice.save();
        }
      }
    }
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
