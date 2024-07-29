// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
 
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {HelperConfig} from "./HelpperConfig.s.sol";
contract script_fund_me is Script{
    function run() external returns(FundMe){
        // before broadcast fake tx, no gas used
        HelperConfig helperconfig = new HelperConfig();
        address EthUsdPricefeed= helperconfig.activeNetworkConfig();
        
        vm.startBroadcast(); //after broadcast real tx , gas used
        FundMe fundme = new FundMe(EthUsdPricefeed);
        vm.stopBroadcast();
        return fundme;
    }
}