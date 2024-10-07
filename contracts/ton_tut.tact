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
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let raffle = self.rafflesBuffer.get(key);
        return raffle;
    }

    get fun getRaffleRandomnessCommitment(key: Int): Int {
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.randomnessCommitment;
    }

    get fun getRaffleCurrentRandomness(key: Int): Int {
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.currentRandomness;
    }

    get fun getRaffleCommitmentOpened(key: Int): Bool {
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let raffle = self.rafflesBuffer.get(key);
        return raffle!!.commitmentOpened;
    }

    get fun getTotalSum(key: Int): Int {
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let tree = self.treesBuffer.get(key);
        return tree!!.totalSum;
    }

    // trees functions

    fun insert(key: Int,account: Address, amount: Int) {
        require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let currentTree = self.treesBuffer.get(key);
        let parent: Address? = newAddress(0,0);
        let current: Address = currentTree!!.root;
        let shouldBreak: Bool = false;
        while (current != newAddress(0,0) || shouldBreak) {
            parent = current;

            let uintParent  = parent!!.toString().asSlice().loadUint(256);
            let uintAccount = account.toString().asSlice().loadUint(256);

            if (parent == account) {
                shouldBreak = true;
            } else if (uintParent > uintAccount) {
                let parentNode: Node = currentTree!!.nodes.get(parent!!)!!;
                parentNode.leftSum += amount;
                current = parentNode.left!!;
                if (current == newAddress(0,0)) {
                    let node: Node = currentTree!!.nodes.get(parent!!)!!;
                        node.left = account;
                }
            } else {
                let node: Node = currentTree!!.nodes.get(parent!!)!!;
                node.rightSum += amount;
                currentTree!!.nodes.set(parent!!, node);
                current = node.right!!;
                if (current == newAddress(0,0)) {
                    let parentNode: Node = currentTree!!.nodes.get(parent!!)!!;
                    parentNode.right = account;
                    currentTree!!.nodes.set(parent!!, parentNode);
                }
            }
        }

        if (current == newAddress(0,0)) {
            currentTree!!.nodes.set(account, Node{
                value: amount,
                left: null,
                leftSum: 0,
                right: null,
                rightSum: 0
            });
        } else {
            let node: Node = currentTree!!.nodes.get(current)!!;
            node.value += amount;
        }

        if (currentTree != null) {
            let tree: Tree = currentTree!!;
            tree.totalSum += amount;
        }
    }

    get fun get(key: Int,account: Address): Int {
         require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let currentTree = self.treesBuffer.get(key);
        let current: Address = currentTree!!.root;

        let uintCurrent = current.toString().asSlice().loadUint(256);
        let uintAccount = account.toString().asSlice().loadUint(256);
        while (current != newAddress(0,0)) {
            if (current == account) {
                let node: Node = currentTree!!.nodes.get(current)!!;
                return node.value;
            } else if (uintCurrent > uintAccount) {
                current = currentTree!!.nodes.get(current)!!.left!!;
            } else {
                current = currentTree!!.nodes.get(current)!!.right!!;
            }
        }

        return 0; 
    }

    get fun getByPointOnInterval(key: Int, value: Int): Address? {
         require(key < 0 || key >= self.currentIndex, "Raffle with this key does not exist");
        let currentTree = self.treesBuffer.get(key);
        let current: Address = currentTree!!.root;

        while (current != newAddress(0,0)) {
            if (value < currentTree!!.nodes.get(current)!!.leftSum) {
                current = currentTree!!.nodes.get(current)!!.left!!;
            } else if (value < currentTree!!.nodes.get(current)!!.leftSum + currentTree!!.nodes.get(current)!!.value) {
                return current;
            } else {
                value -= currentTree!!.nodes.get(current)!!.leftSum + currentTree!!.nodes.get(current)!!.value;
                current = currentTree!!.nodes.get(current)!!.right!!;
            }
        }

        return null; 
    }
}