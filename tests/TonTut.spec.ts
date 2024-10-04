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

        tonTut = blockchain.openContract(await TonTut.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await tonTut.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
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
});
