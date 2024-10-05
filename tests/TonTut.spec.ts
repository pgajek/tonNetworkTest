import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { TonTut } from '../wrappers/TonTut';
import '@ton/test-utils';

describe('TonTut', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let tonTut: SandboxContract<TonTut>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        tonTut = blockchain.openContract(await TonTut.fromInit(0n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await tonTut.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 1n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: tonTut.address,
            deploy: true,
            success: true,
        });
    });

    describe('Basic functionality', ()=>{
        it('should deploy', async () => {
            // the check is done inside beforeEach
            // blockchain and tonTut are ready to use
        });
        it('should increase counter', async () => {
            const increaseTimes = 3;
            for(let i = 0; i < increaseTimes; i++){
                console.log(`increase ${i+1}/${increaseTimes}`);
    
                const increaser = await blockchain.treasury('increaser' + i);
    
                const counterBefore = await tonTut.getCounter();
                console.log("Counter before", counterBefore);
    
                const increaseBy = BigInt(Math.floor(Math.random() * 100));
    
                console.log(`increasing by ${increaseBy}`);
    
                const increaseResult = await tonTut.send(
                    increaser.getSender(),
                    {
                        value: toNano('0.05'),
                    },
                    {
                        $$type: "Add",
                        queryId: 0n,
                        amount: increaseBy
                    }
                );
                expect(increaseResult.transactions).toHaveTransaction({
                    from: increaser.address,
                    to: tonTut.address,
                    success: true,
                });
    
                const counterAfter = await tonTut.getCounter();
                console.log("Counter after", counterAfter);
    
                expect(counterAfter).toBe(counterBefore + increaseBy);
                
            }
        });
        it('should change owner', async () => {
            const newOwner = await blockchain.treasury('newOwner');
    
            const ownerBefore = await tonTut.getOwner();
            console.log("Owner before", ownerBefore.toString());
            console.log("deployer address", deployer.address.toString());
            
            expect(ownerBefore.toString()).toBe(deployer.address.toString());
    
            const changeOwnerResult = await tonTut.send(
                deployer.getSender(),
                {
                    value: toNano('0.05'),
                },
                {
                    $$type: "ChangeOwner",
                    newOwner: newOwner.address,
                }
            );
    
            expect(changeOwnerResult.transactions).toHaveTransaction({
                from: deployer.address,
                to: tonTut.address,
                success: true,
            });
    
            const ownerAfter = await tonTut.getOwner();
            console.log("Owner after", ownerAfter.toString());
    
            expect(ownerAfter.toString()).toBe(newOwner.address.toString());
        });
    })
    describe('Tree functionality', ()=>{
        it('correctly inserts nodes', async () => {});
        it('correctly getting nodes', async () => {});
        it('correctly getting by point on interval', async () => {});
        it('correctly handles non existen account', async () => {});
    })
    describe('Raffle functionality', ()=>{
        it('correctly creates new game', async () => {});
        it('should fail creating new game if signarute is not valid', async () => {});
        it('correctly increases player amount', async () => {});
        it('fails increasing player amount if signature is not valid', async () => {});
        it('should return correct winner', async () => {});
        it('should return correct winner with boundary values', async () => {});
        it('invalid randomness', async () => {});
        it('replay attack same game', async () => {});
        it('replay attack different game', async () => {});
        it('should correctly pause and unpause', async () => {});
        it('should correctly return raffle details', async () => {});
        //////
        it('bound or default with equal min max', async () => {});
        it('get winner with zero total sum', async () => {});
        it('raffle tickets commitment already opened', async () => {});
        it('get raffle tickets invalid raffleId', async () => {});
        it('new raffle when game not concluded', async () => {});
        it('multiple participation', async () => {});
        it('add player', async () => {});
        it('benchmark many users', async () => {});
    });
});