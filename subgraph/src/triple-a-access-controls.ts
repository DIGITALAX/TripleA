import { ByteArray, Bytes, store } from "@graphprotocol/graph-ts"
import {
  AdminAdded as AdminAddedEvent,
  AdminRemoved as AdminRemovedEvent,
  FaucetUsed as FaucetUsedEvent,
  FulfillerAdded as FulfillerAddedEvent,
  FulfillerRemoved as FulfillerRemovedEvent,
  TokenDetailsRemoved as TokenDetailsRemovedEvent,
  TokenDetailsSet as TokenDetailsSetEvent,
} from "../generated/TripleAAccessControls/TripleAAccessControls"
import {
  AdminAdded,
  AdminRemoved,
  FaucetUsed,
  FulfillerAdded,
  FulfillerRemoved,
  TokenDetailsRemoved,
  TokenDetailsSet,
} from "../generated/schema"

export function handleAdminAdded(event: AdminAddedEvent): void {
  let entity = new AdminAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleAdminRemoved(event: AdminRemovedEvent): void {
  let entity = new AdminRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFaucetUsed(event: FaucetUsedEvent): void {
  let entity = new FaucetUsed(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.to = event.params.to
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFulfillerAdded(event: FulfillerAddedEvent): void {
  let entity = new FulfillerAdded(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFulfillerRemoved(event: FulfillerRemovedEvent): void {
  let entity = new FulfillerRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.admin = event.params.admin

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTokenDetailsRemoved(
  event: TokenDetailsRemovedEvent
): void {
  let entity = new TokenDetailsRemoved(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.params.token;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  let tokenEntity = new TokenDetailsSet(
    Bytes.fromByteArray(
      ByteArray.fromHexString(event.params.token.toHexString())
    )
  );

  if (tokenEntity) {
    store.remove(
      "TokenDetailsRemoved",
      Bytes.fromByteArray(
        ByteArray.fromHexString(event.params.token.toHexString())
      ).toHexString()
    );
  }
}

export function handleTokenDetailsSet(event: TokenDetailsSetEvent): void {
  let entity = new TokenDetailsSet(
    Bytes.fromByteArray(
      ByteArray.fromHexString(event.params.token.toHexString())
    )
  );
  entity.token = event.params.token;
  entity.threshold = event.params.threshold;
  entity.rentLead = event.params.rentLead;
  entity.rentRemix = event.params.rentRemix;
  entity.rentPublish = event.params.rentPublish;
  entity.vig = event.params.vig;
  entity.base = event.params.base;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();
}