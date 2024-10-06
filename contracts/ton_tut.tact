import "@stdlib/deploy";

// import "@stdlib/ownable";

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
message CreateNewRaffle {
    key: Int as uint256;
    randomnessCommitment: Int as uint256;
}
// structs
struct Raffle {
    randomnessCommitment: Int as uint256;
    currentRandomness: Int as uint256;
    commitmentOpened: Bool;
    playerNonces: map<Address, Int as uint256>;
}
struct Node {
    value: Int as uint256;
    left: Address?;
    leftSum: Int as uint256;
    right: Address?;
    rightSum: Int as uint256;
}
struct Tree {
    root: Address;
    totalSum: Int as uint256;
    nodes: map<Address, Node>;
}

contract TonTut with Deployable {
    owner: Address;
    rafflesBuffer: map<Int as uint256, Raffle>;
    treesBuffer: map<Int as uint256, Tree>;
    currentIndex: Int as int8;
    maxIndex: Int as int8;
    init(maxIndex: Int){
        self.currentIndex = 0;
        self.maxIndex = maxIndex;
        self.owner = sender();
    }

    receive("pause"){}

    receive("unpause"){}

    receive(msg: CrackTheEggMessage){
        emit(CrackTheEggEvent{sender: sender(), timestamp: now(), data: msg.data}.toCell());
    }

    receive(msg: ChangeOwner){
        self.owner = msg.newOwner;
    }

    get fun owner(): Address {
        return self.owner;
    }

    fun increaseIndex() {
        self.currentIndex += 1;
        if (self.currentIndex > self.maxIndex) {
            self.currentIndex = 0;
        }
    }

    receive(msg: CreateNewRaffleMessage){
        self.rafflesBuffer.set(self.currentIndex,
            Raffle{
                randomnessCommitment: msg.randomnessCommitment,
                currentRandomness: 0,
                commitmentOpened: false,
                playerNonces: emptyMap()
            }
        );
        self.treesBuffer.set(self.currentIndex,
            Tree{root: newAddress(0, 0x7fFFfFfFFFfFFFFfFffFfFfFfffFFfFfFffFFFFf), totalSum: 0, nodes: emptyMap()}
        );
        self.increaseIndex();
        emit(RaffleCreatedEvent{raffleId: self.currentIndex, randomnessCommitment: msg.randomnessCommitment}.toCell());
    }

    // function initialize(Tree storage self) internal {
    //     self.root = address(0x7fFFfFfFFFfFFFFfFffFfFfFfffFFfFfFffFFFFf);
    //     self.totalSum = 0;
    // }
    //   function newRaffle(bytes32 raffleId, bytes32 randomnessCommitment) external whenNotPaused onlyOwner {
    //     if (raffleExists[raffleId]) revert RaffleAlreadyExists();
    //     raffles[raffleId].tree.initialize();
    //     raffles[raffleId].randomnessCommitment = randomnessCommitment;
    //     raffles[raffleId].currentRandomness = randomnessCommitment;
    //     emit RaffleCreated(raffleId, randomnessCommitment);
    // }
}