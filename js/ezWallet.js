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
  console.log(JSON.stringify(accKeyArr));
};
//set_withdraw_vesting_route(from,to,percent,autovests,broadcast)
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
    reqArr.push(0);
    reqArr.push(0);
  });

  //for each miner name, call set_withdraw_vesting_route
  for(i = 0; i < minerAccountArray.length; i++){
    reqArr.unshift(minerAccountArray[i]);
    client.request('set_withdraw_vesting_route', reqArr, function(err, response){

    });
    reqArr.shift();
  }

};
getWithdrawVestingRoute();
TODO //Some function for importing all of the miner keys and accounts into cli_wallet, then locking them via user password
    //then we will be able to use getWithdrawVestingRoute()
