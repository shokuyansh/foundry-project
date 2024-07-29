pragma solidity ^0.8.18;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {script_fund_me} from "../../script/Deploy_FundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Integration.s.sol";

contract FundMeIntegration is Test{
    FundMe fundme;
    address USER=makeAddr("user") ;//CHEATCODE
    uint256 constant SEND_VALUE=0.1 ether; //100000000000000000
    uint constant STARTING_BALANCE=10 ether; 
    uint constant GAS_PRICE=1;
    function setUp() external{
        script_fund_me deploy=new script_fund_me();
         fundme=deploy.run();
          vm.deal(USER,STARTING_BALANCE);
    }
    function testUserCanFund() public{
        FundFundMe fundfundme=new FundFundMe();
        fundfundme.fundFundMe(address(fundme));

        WithdrawFundMe withdrawfundme= new WithdrawFundMe();
        withdrawfundme.withdrawFundMe(address(fundme));
        assert(address(fundme).balance==0);
    }
}