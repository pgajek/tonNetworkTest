import "@stdlib/deploy";

struct Node {
    value: Int as uint256;
    left: Address?;
    leftSum: Int as uint256;
    right: Address?;
    rightSum: Int as uint256;
}

contract IntervalTree with Deployable {
    root: Address;
    totalSum: Int as uint256;
    nodes: map<Address, Node>;

    init() {
        self.root = newAddress(0,0x7fFFfFfFFFfFFFFfFffFfFfFfffFFfFfFffFFFFf);
        self.totalSum = 0;
    }

    fun insert(account: Address, amount: Int) {
        let parent: Address? = newAddress(0,0);
        let current: Address = self.root;
        let shouldBreak: Bool = false;
        while (current != newAddress(0,0) || shouldBreak) {
            parent = current;

            let uintParent  = parent!!.toString().asSlice().loadUint(256);
            let uintAccount = account.toString().asSlice().loadUint(256);

            if (parent == account) {
                shouldBreak = true;
            } else if (uintParent > uintAccount) {
                let parentNode: Node = self.nodes.get(parent!!)!!;
                parentNode.leftSum += amount;
                current = parentNode.left!!;
                if (current == newAddress(0,0)) {
                    let node: Node = self.nodes.get(parent!!)!!;
                        node.left = account;
                }
            } else {
                let node: Node = self.nodes.get(parent!!)!!;
                node.rightSum += amount;
                self.nodes.set(parent!!, node);
                current = node.right!!;
                if (current == newAddress(0,0)) {
                    let parentNode: Node = self.nodes.get(parent!!)!!;
                    parentNode.right = account;
                    self.nodes.set(parent!!, parentNode);
                }
            }
        }

        if (current == newAddress(0,0)) {
            self.nodes.set(account, Node{
                value: amount,
                left: null,
                leftSum: 0,
                right: null,
                rightSum: 0
            });
        } else {
            let node: Node = self.nodes.get(current)!!;
            node.value += amount;
        }

        self.totalSum += amount;
    }

    get fun get(account: Address): Int {
        let current: Address = self.root;

        let uintCurrent = current.toString().asSlice().loadUint(256);
        let uintAccount = account.toString().asSlice().loadUint(256);
        while (current != newAddress(0,0)) {
            if (current == account) {
                let node: Node = self.nodes.get(current)!!;
                return node.value;
            } else if (uintCurrent > uintAccount) {
                current = self.nodes.get(current)!!.left!!;
            } else {
                current = self.nodes.get(current)!!.right!!;
            }
        }

        return 0; 
    }

    get fun getByPointOnInterval(value: Int): Address? {
        let current: Address = self.root;

        while (current != newAddress(0,0)) {
            if (value < self.nodes.get(current)!!.leftSum) {
                current = self.nodes.get(current)!!.left!!;
            } else if (value < self.nodes.get(current)!!.leftSum + self.nodes.get(current)!!.value) {
                return current;
            } else {
                value -= self.nodes.get(current)!!.leftSum + self.nodes.get(current)!!.value;
                current = self.nodes.get(current)!!.right!!;
            }
        }

        return null; 
    }
}