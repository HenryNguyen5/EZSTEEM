//This is a javascript wrapper for steem cli_wallet
//Usage: ./ezWallet.js EZSTEEMDir
var jayson = require('./node_modules/jayson');
var prompt = require('./node_modules/prompt');
var fs = require('fs');
//create a client to interact with cli_wallet
var client = jayson.client.http('http://127.0.0.1:8091');
var minerAccountArray = [];
var minerKeyArray = [];
var EZSTEEMDir = process.argv[2];
var boolTrue = 1;
var boolFalse = 0;

//fill in the miners names and keys
var getMinerInfo = function(err, rawContents){
  //split on new lines
  var accKeyArr = [];
  var lines = rawContents.split(/\n/);
  //iterate through the lines until value of interest is found
  //find miner = [NAME,KEY] and store only the [NAME,KEY] into accKeyArr
  for(i = 0; i < lines.length; i++){
    if(lines[i].match("/^miner =/")){
      var minerArr = lines[i].split(" ");
      accKeyArr += minerArr[2];
    }
  }
  console.log(accKeyArr);
  TODO
  //Seperate NAME and KEY into their respective arrays, minerAccountArray and minerKeyArray
  console.log(JSON.parse(accKeyArr));
  accKeyArr = JSON.parse(accKeyArr);
};


//set_withdraw_vesting_route(from,to,percent,autovests,broadcast)
/*gethelp set_withdraw_vesting_route

Set up a vesting withdraw route. When vesting shares are withdrawn, they
will be routed to these accounts based on the specified weights.

Parameters:
from: The account the VESTS are withdrawn from. (type: string)
to: The account receiving either VESTS or STEEM. (type: string)
percent: The percent of the withdraw to go to the 'to' account. This is
denoted in hundreths of a percent. i.e. 100 is 1% and 10000 is
100%. This value must be between 1 and 100000 (type: uint16_t)
auto_vest: Set to true if the from account should receive the VESTS as
VESTS, or false if it should receive them as STEEM. (type: bool)
broadcast: true if you wish to broadcast the transaction. (type: bool)
*/
var getWithdrawVestingRoute = function(){
  //fill in required miner arrays
  fs.readfile(EZSTEEMDir,getMinerInfo);

  var reqArr = [];
  //prompt the user for their destination wallet and the percentile
  var schema = {
    properties: {
      dst: {
        description: "Which account do you want to transfer all of your miner accounts SteemPower to?"
      },
      percent: {
        description: "What percentage of the SteemPower mined would you like to send? (1-100)%"
      }
    }
  };
  prompt.start();

  prompt.get(schema, function(err, result){
    result.percent *= 100;
    for (var results in result){
      reqArr.push(results);
      console.log(results);
    }
    //1 is true
    //0 is false
    reqArr.push(boolFalse);
    reqArr.push(boolFalse);
  });

  //for each miner name, call set_withdraw_vesting_route
  for(i = 0; i < minerAccountArray.length; i++){
    reqArr.unshift(minerAccountArray[i]);
    client.request('set_withdraw_vesting_route', reqArr, function(err, response){

    });
    reqArr.shift();
  }
};


/*
gethelp set_password

Sets a new password on the wallet.

The wallet must be either 'new' or 'unlocked' to execute this command.
*/
var setWalletPass = function(){

};


/*
gethelp import_key

Imports a WIF Private Key into the wallet to be used to sign transactions
by an account.

example: import_key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

Parameters:
wif_key: the WIF Private Key to import (type: string)
*/
var importMinerPrivateKeys =  function(){

};

/*
gethelp unlock

Unlocks the wallet.

The wallet remain unlocked until the 'lock' is called or the program exits.

Parameters:
password: the password previously set with 'set_password()' (type:
string)
*/
var unlockWallet = function(){

};

/*gethelp is_locked

Checks whether the wallet is locked (is unable to use its private keys).

This state can be changed by calling 'lock()' or 'unlock()'.

Returns
true if the wallet is locked
*/
var isLocked = function(){

};
getWithdrawVestingRoute();
TODO //Some function for importing all of the miner keys and accounts into cli_wallet, then locking them via user password
    //then we will be able to use getWithdrawVestingRoute()
