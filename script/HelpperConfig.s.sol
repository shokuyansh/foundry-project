//1. Deploy mocks when we are on alocal chain
//2. keep track of contract addresses across different chains
// for eg speoila eth/usd
//for eg mainnet eth/usd

// SPDX-License-Identifier: MIT
pragma solidity 
^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";
contract HelperConfig is Script{
// if we are on a local anvil ,we deploy mocks
// otherwise, grab the existing address from the live network
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER=2000e8;
    struct NetWorkConfig {
        address pricefeed;
    }
    NetWorkConfig public activeNetworkConfig;
    constructor(){
        if(block.chainid==11155111) //11155111 sepolia chain id
        { activeNetworkConfig=getSepolia_ethconfig();
        }
        else if(block.chainid==1)
        {
            activeNetworkConfig=getMainnet_ethconfig();
        }
        else {
            activeNetworkConfig=getorcreateAnvil_ethconfig();
        }
    }

    function getSepolia_ethconfig() public pure returns(NetWorkConfig memory){
        NetWorkConfig memory sepoliaconfig = NetWorkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaconfig;
    }
     function getMainnet_ethconfig() public pure returns(NetWorkConfig memory){
        NetWorkConfig memory mainnetconfig = NetWorkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return mainnetconfig;
    }
    

    function getorcreateAnvil_ethconfig() public  returns(NetWorkConfig memory){
            if(activeNetworkConfig.pricefeed!=address(0))  // means if we have not set price feed to something then run the function or else we have already given the address
            {    return activeNetworkConfig;}   
            // deploy mock contracts
            // get mock address in return
            vm.startBroadcast();
            MockV3Aggregator mockpricefeed=new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
            vm.stopBroadcast(); 
            NetWorkConfig memory Anvilconfig= NetWorkConfig(address(mockpricefeed));
            return Anvilconfig;
    }
}