import "@stdlib/deploy";
message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}
message AddEvent {
    queryId: Int as uint64;
    amount: Int as uint32;
    counter: Int as uint32;
}
message ChangeOwner {
    newOwner: Address;
}
message CrackTheEggMessage {
    data: Int as uint256;
}
message CrackTheEggEvent {
    sender: Address;
    timestamp: Int as uint64;
    data: Int as uint256;
}
message RaffleCreatedEvent {
    raffleId: Int as uint256;
    randomnessCommitment: Int as uint256;
}
message PlayerAmountIncreasedEvent {
    raffleId: Int as uint256;
    player: Address;
    amount: Int as uint256;
    nonce: Int as uint256;
}
message WinnerDeclaredEvent {
    raffleId: Int as uint256;
    winner: Address;
}
message GetRaffleMessage {
    key: Int as uint256;
}
message GetRaffleRandomnessCommitmentMessage {
    key: Int as uint256;
}
message GetRaffleCurrentRandomnessMessage {
    key: Int as uint256;
}
message GetRaffleCommitmentOpenedMessage {
    key: Int as uint256;
}
message GetRaffleExistsMessage {
    key: Int as uint256;
}
message GetTotalSumMessage {
    key: Int as uint256;
}
message CreateNewRaffleMessage {
    key: Int as uint256;
    randomnessCommitment: Int as uint256;
}
struct Raffle {
    randomnessCommitment: Int as uint256;
    currentRandomness: Int as uint256;
    commitmentOpened: Bool;
    playerNonces: map<Address, Int as uint256>;
}

contract TonTut with Deployable {
    id: Int as uint32;
    counter: Int as uint32;
    owner: Address;
    init(id: Int){
        self.id = id;
        self.counter = 0;
        self.owner = sender();
    }

    receive(msg: Add){
        self.counter += msg.amount;
        emit("Counter incremented".asComment());
        emit(AddEvent{queryId: msg.queryId, amount: msg.amount, counter: self.counter}.toCell());
    }

    receive("pause"){}

    receive("unpause"){}

    receive(msg: CrackTheEggMessage){
        emit(CrackTheEggEvent{sender: sender(), timestamp: now(), data: msg.data}.toCell());
    }

    receive(msg: ChangeOwner){
        self.owner = msg.newOwner;
    }

    get fun counter(): Int {
        return self.counter;
    }

    get fun id(): Int {
        return self.id;
    }

    get fun owner(): Address {
        return self.owner;
    }
}