// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {script_fund_me} from "../../script/Deploy_FundMe.s.sol";
// What can we do to work with addresses outside our system?
//1. Unit
//       - testing aspecific part of our code
//2. Integration
//              -Testing how our code works with other parts of our code
//3. Forked
//          - Testing our code on a simulated real environment
//4. Staging
//          - Testing our code in a real environment that is not prod but like testnet or mainnet
contract test_fund_me is Test{
    FundMe fundme;
    address USER=makeAddr("user");//CHEATCODE
    uint256 constant SEND_VALUE=0.1 ether; //100000000000000000
    uint constant STARTING_BALANCE=10 ether; 
    uint constant GAS_PRICE=1;
    function setUp() external{
        //fundme=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
         script_fund_me deploy_fundme=new script_fund_me();
         fundme=deploy_fundme.run();
        //us->test_fund_me -> fundme , so owner of fundme is test_fund_me not us
        vm.deal(USER,STARTING_BALANCE); //CHEATCODE
    }
    function testMinimumUSD_is_5() public view{
        assertEq(fundme.MINIMUM_USD(),5e18);
    }
    function test_Owner_is_MsgSender() public view{
        assertEq(fundme.i_owner(),msg.sender);
    }
    function test_getversion() public view{
        uint version=fundme.getVersion();
        assertEq(version,4);
    //w/o url foundry runs the contact on temp blank anvil , which is why test fail , cause no address exists on it, with forked we can simulate sepiola on anvil as i sepiola was running these
    }
    function testfundfailswithoutenoughtETH() public{
        vm.expectRevert(); // hey , the next line should revert, then only will the test pass, this cheatcode works in testing only
        //assert(this tx fails/revert)
        //next tx will fail , making test pass
        fundme.fund();//send 0 value , this tx will fail making test pass
    }
    function testfundupdatesfundeddatastructure() public{
       vm.prank(USER);//NEXT TX WILL be sent by user//CHEATCODE
       fundme.fund{value:SEND_VALUE}();
       uint256 amountFunded=fundme.getAddresstoamountfunded(USER);
       assertEq(amountFunded,SEND_VALUE);

    }
    function testAddsFundertoarrayofFunders() public{
        vm.prank(USER);//NEXT TX WILL be sent by user//CHEATCODE
       fundme.fund{value:SEND_VALUE}();
       address funderadd=fundme.getFunder(0);
       assertEq(funderadd,USER);
    }
    modifier funder{
        vm.prank(USER);//NEXT TX WILL be sent by user//CHEATCODE
        fundme.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funder{
      
       vm.expectRevert(); // it's gonna ignore the vm cheatcodes below it 
       vm.prank(USER);
       fundme.withdraw();
    }

    event GasUsed(uint indexed _gasused);
    function testWithdrawWithASingleOwner() public funder{
        //Arrange
        uint startingfundownerBalance=fundme.getOwner().balance;
        uint startingfundmebalance=address(fundme).balance;
        //Act
        uint gasatstart=gasleft();
        vm.txGasPrice(GAS_PRICE); // cheatcode to set gasprice for upcoming tx
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint gasatend=gasleft();
        uint gasused =(gasatstart-gasatend)*tx.gasprice;//tx.gasprice tells current gasprice
        
        emit GasUsed(gasused);
        //Assert
        uint endingfundownerBalace=fundme.getOwner().balance;
        uint endingfundmeBalance=address(fundme).balance;
        assertEq(endingfundmeBalance,0);
        assertEq(startingfundmebalance+startingfundownerBalance,endingfundownerBalace);
    }
    function testWithdrawFromMultipleFunders() public funder{
        //Arrange
        uint160 numberoffunders=10;
        uint160 funderindex=1;
        for(uint160 i=funderindex;i<numberoffunders;i++)
        {
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        uint256 StartingOwnerBalance=fundme.getOwner().balance;
        uint256 StartingFundMeBalance=address(fundme).balance;
        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        //assert
        assert(address(fundme).balance==0);
        assert(StartingFundMeBalance+StartingOwnerBalance==fundme.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funder{
        //Arrange
        uint160 numberoffunders=10;
        uint160 funderindex=1;
        for(uint160 i=funderindex;i<numberoffunders;i++)
        {
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }
        uint256 StartingOwnerBalance=fundme.getOwner().balance;
        uint256 StartingFundMeBalance=address(fundme).balance;
        //Act
        vm.startPrank(fundme.getOwner());
        fundme.CheaperWithdraw();
        vm.stopPrank();
        //assert
        assert(address(fundme).balance==0);
        assert(StartingFundMeBalance+StartingOwnerBalance==fundme.getOwner().balance);
    }
    }