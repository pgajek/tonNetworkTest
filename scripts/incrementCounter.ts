import { NetworkProvider, sleep } from "@ton/blueprint";
import { TonTut } from "../wrappers/TonTut";
import { Address, toNano } from "@ton/core";

export async function run(provider: NetworkProvider) {
    const tonTut = provider.open(TonTut.fromAddress(Address.parse("EQDfV7b4erPx-K0CBQPDolTvcLrZyN4Z0GZhR7I6neyIcROF")));

   const counterBefore = await tonTut.getCounter();
   console.log("Counter before", counterBefore);

   await tonTut.send(
    provider.sender(),
    {
        value:toNano("0.05")
    },
    {
        $$type: "Add",
        queryId: 0n,
        amount: 1n
    }
   );

   let counterAfter = await tonTut.getCounter();
   let attempt = 1;
   while(counterAfter === counterBefore){
    console.log("incremeting counter, attempt#",attempt);
    await sleep(2000);

    counterAfter = await tonTut.getCounter();
    console.log("Counter after", counterAfter);
    attempt++;
   }

   console.log("Counter after", counterAfter);
   console.log("Attempts", attempt);
}