import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AgentFundsWithdrawn,
  AgentOwnerPaid,
  FundsReceived,
  FundsWithdrawn,
  OrderPayment
} from "../generated/AAADevTreasury/AAADevTreasury"

export function createAgentFundsWithdrawnEvent(
  tokens: Array<Address>,
  amounts: Array<BigInt>,
  agent: Address
): AgentFundsWithdrawn {
  let agentFundsWithdrawnEvent = changetype<AgentFundsWithdrawn>(newMockEvent())

  agentFundsWithdrawnEvent.parameters = new Array()

  agentFundsWithdrawnEvent.parameters.push(
    new ethereum.EventParam("tokens", ethereum.Value.fromAddressArray(tokens))
  )
  agentFundsWithdrawnEvent.parameters.push(
    new ethereum.EventParam(
      "amounts",
      ethereum.Value.fromUnsignedBigIntArray(amounts)
    )
  )
  agentFundsWithdrawnEvent.parameters.push(
    new ethereum.EventParam("agent", ethereum.Value.fromAddress(agent))
  )

  return agentFundsWithdrawnEvent
}

export function createAgentOwnerPaidEvent(
  token: Address,
  owner: Address,
  amount: BigInt
): AgentOwnerPaid {
  let agentOwnerPaidEvent = changetype<AgentOwnerPaid>(newMockEvent())

  agentOwnerPaidEvent.parameters = new Array()

  agentOwnerPaidEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  agentOwnerPaidEvent.parameters.push(
    new ethereum.EventParam("owner", ethereum.Value.fromAddress(owner))
  )
  agentOwnerPaidEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return agentOwnerPaidEvent
}

export function createFundsReceivedEvent(
  buyer: Address,
  token: Address,
  amount: BigInt
): FundsReceived {
  let fundsReceivedEvent = changetype<FundsReceived>(newMockEvent())

  fundsReceivedEvent.parameters = new Array()

  fundsReceivedEvent.parameters.push(
    new ethereum.EventParam("buyer", ethereum.Value.fromAddress(buyer))
  )
  fundsReceivedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  fundsReceivedEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return fundsReceivedEvent
}

export function createFundsWithdrawnEvent(
  token: Address,
  amount: BigInt
): FundsWithdrawn {
  let fundsWithdrawnEvent = changetype<FundsWithdrawn>(newMockEvent())

  fundsWithdrawnEvent.parameters = new Array()

  fundsWithdrawnEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  fundsWithdrawnEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return fundsWithdrawnEvent
}

export function createOrderPaymentEvent(
  token: Address,
  recipient: Address,
  amount: BigInt
): OrderPayment {
  let orderPaymentEvent = changetype<OrderPayment>(newMockEvent())

  orderPaymentEvent.parameters = new Array()

  orderPaymentEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  orderPaymentEvent.parameters.push(
    new ethereum.EventParam("recipient", ethereum.Value.fromAddress(recipient))
  )
  orderPaymentEvent.parameters.push(
    new ethereum.EventParam("amount", ethereum.Value.fromUnsignedBigInt(amount))
  )

  return orderPaymentEvent
}
