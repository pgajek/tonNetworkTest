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
});
