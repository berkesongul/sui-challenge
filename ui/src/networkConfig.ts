import { getFullnodeUrl } from "@mysten/sui/client";
import { createNetworkConfig } from "@mysten/dapp-kit";

/**
there are packageId and other network test area informations
 */
const PACKAGE_ID = "0xd406fb6bd00b4bd234a8982b8b3016d63a85daf5f37c366d8907316f457a5ed0";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
  createNetworkConfig({
    devnet: {
      url: getFullnodeUrl("devnet"),
      variables: { packageId: PACKAGE_ID },
    },
    testnet: {
      url: getFullnodeUrl("testnet"),
      variables: { packageId: "0xebc052900562895217ed079d540294faf3a08323c23f8a4830058bbe34f3a7d1" },
    },
    mainnet: {
      url: getFullnodeUrl("mainnet"),
      variables: { packageId: PACKAGE_ID },
    },
  });

export { useNetworkVariable, useNetworkVariables, networkConfig };