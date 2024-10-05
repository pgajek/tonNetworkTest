import "@stdlib/deploy";
message Add {
    queryId: Int as uint64;
    amount: Int as uint32;
}
message ChangeOwner {
    newOwner: Address;
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