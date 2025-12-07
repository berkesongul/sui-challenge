import { Transaction } from "@mysten/sui/transactions";

export const buyHero = (packageId: string, listHeroId: string, priceInSui: string) => {
  const tx = new Transaction();
  
  // Yazım hatası duzeltildi.
  const priceInMist = Number(priceInSui) * 1_000_000_000;
  
  // 2. Split (bölme) işleminde düzeltilen değişken adını kullanın
  const [paymentCoin] = tx.splitCoins(tx.gas, [priceInMist]);
  
  tx.moveCall({
    "target": `${packageId}::marketplace::buy_hero`,
    "arguments": [
      tx.object(listHeroId),
      paymentCoin
    ]
  });
    
  return tx;
};