import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
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
// message PlayerAmountIncreasedEvent {
//     raffleId: Int as uint256;
//     player: Address;
//     amount: Int as uint256;
//     nonce: Int as uint256;
// }
// message WinnerDeclaredEvent {
//     raffleId: Int as uint256;
//     winner: Address;
// }
message CreateNewRaffleMessage {
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

contract TonTut with Deployable, OwnableTransferable, Resumable {
    owner: Address;
    stopped: Bool;
    rafflesBuffer: map<Int as uint256, Raffle>;
    treesBuffer: map<Int as uint256, Tree>;
    currentIndex: Int as int8;
    maxIndex: Int as int8;
    init(maxIndex: Int){
        self.stopped = false;
        self.currentIndex = 0;
        self.maxIndex = maxIndex;
        self.owner = sender();
    }

    receive(msg: CrackTheEggMessage){
        emit(CrackTheEggEvent{sender: sender(), timestamp: now(), data: msg.data}.toCell());
    }

    get fun getOwner(): Address {
        return self.owner;
    }

    fun increaseIndex() {
        self.currentIndex += 1;
        if (self.currentIndex > self.maxIndex) {
            self.currentIndex = 0;
        }
    }

    receive(msg: CreateNewRaffleMessage){
        self.requireNotStopped(); // cant work if a contract is stopped
        self.rafflesBuffer.set(self.currentIndex,
            Raffle{
                randomnessCommitment: msg.randomnessCommitment,
                currentRandomness: msg.randomnessCommitment,
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

    get fun getRaffle(key: Int): Raffle? {
        let raffle = self.rafflesBuffer.get(key);
        return raffle;
    }

    get fun getRaffleRandomnessCommitment(key: Int): Int {
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.randomnessCommitment;
    }

    get fun getRaffleCurrentRandomness(key: Int): Int {
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.currentRandomness;
    }

    get fun getRaffleCommitmentOpened(key: Int): Bool {
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.commitmentOpened;
    }

    get fun getTotalSum(key: Int): Int {
        let tree = self.treesBuffer.get(key);
        return tree!!.totalSum;
    }
}