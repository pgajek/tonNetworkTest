import { toNano } from '@ton/core';
import { TonTut } from '../wrappers/TonTut';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const tonTut = provider.open(await TonTut.fromInit());

    await tonTut.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(tonTut.address);

    // run methods on `tonTut`
}
