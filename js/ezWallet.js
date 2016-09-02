//This is a javascript wrapper for steem cli_wallet
//Usage: nodejs ezWallet.js
//ORDER OF EXCECUTION:is_locked->set_password->unlock->getSteemConfFile->
//importMinerPrivateKeys->set_withdraw_vesting_route->list_my_accounts->withdrawVesting

/*jshint esversion: 6*/
var jayson = require('./node_modules/jayson');
var prompt = require('./node_modules/prompt');
var fs = require('fs');
var helper = require('./helper.js');
var colors = require('colors');
var rpcIDs = {
    setWithdrawVestingRouteID: 1,
    setWalletPassID: 2,
    importMinerPrivateKeysID: 3,
    unlockWalletID: 4,
    isLockedID: 5,
    isNewID: 6,
    withdrawVestingID: 7,
    listMyAccountsID: 8,
    infoID: 9
};

//create a client to interact with cli_wallet
//MAKE SURE YOU SPAWN CLI_WALLET WITH -r
var client = jayson.client.http('http://127.0.0.1:8091');
var minerAccountArray = [];
var minerKeyArray = [];
var steemConf = "";
var dst = "";
var steemPowerRatio;
//get the config dir from ezsteem conf
//then read the config file and call required callback
var getSteemConfFile = function(callback) {
    var EZSTEEMDir = '/etc/ezsteem.conf';
    //grab config file location from ezsteem.conf
    fs.readFile(EZSTEEMDir, 'utf8', function(err, rawContents) {
        if (err) {
            console.log("An error has occured with getSteemConfFile");
            throw err;
        }
        var lines = rawContents.split(/\n/);
        for (var line in lines) {
            if (lines[line].match(/myConfigFile/)) {
                steemConf = lines[line].split('=')[1];
            }
        }
        return fs.readFile(steemConf, 'utf8', callback);
    });
};

//fill in the miners names and keys
var getMinerInfo = function(err, rawContents) {
    if (err) {
        console.log("An error has occured with getMinerInfo");
        throw err;
    }
    minerAccountArray.length = 0;
    minerKeyArray.length = 0;
    var accKeyArr = [];
    //split on new lines
    var lines = rawContents.split(/\n/);
    //iterate through the lines until value of interest is found
    //find miner = [NAME,KEY] and store only the [NAME,KEY] into accKeyArr
    for (i = 0; i < lines.length; i++) {
        if (lines[i].match(/^miner = /)) {
            var minerArr = JSON.parse(lines[i].split(" ")[2]);
            accKeyArr = accKeyArr.concat(minerArr);
        }
    }
    //Seperate NAME and KEY into their respective arrays, minerAccountArray and minerKeyArray
    for (i = 0; i < accKeyArr.length; i++) {
        if (i % 2 === 0) {
            minerAccountArray.push(accKeyArr[i]);
        } else {
            minerKeyArray.push(accKeyArr[i]);
        }
    }
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
var setWithdrawVestingRoute = function(callback) {
    //fill in required miner arrays
    var reqArr = [];
    //prompt the user for their destination wallet and the percentile
    var schema = {
        properties: {
            dst: {
                description: '\nWhich account do you want to transfer all of your miner accounts SteemPower to?\n',
                type: 'string',
                required: true
            }
        }

    };
    prompt.start();
    prompt.get(schema, function(err, result) {
        dst = result.dst;
        //from
        reqArr.push(result.dst);
        //100% steem power
        reqArr.push(10000);
        //auto_vest
        reqArr.push(false);
        //broadcast
        reqArr.push(true);
        //for each miner name, call set_withdraw_vesting_route
        //possible change: allow user to select what miners to transfer their steem power
        //instead of automatically looping through all accounts
        //(or give both options)
        //should be using rpc call get_account to verify account names
        minerAccountArray.forEach((acc, i) => {
            reqArr.unshift(acc);
            client.request('set_withdraw_vesting_route', reqArr, rpcIDs.setWithdrawVestingRouteID + i, function(err, response) {
                if (err) {
                    console.log('An error with set_withdraw_vesting_route has occured');
                    throw err;
                }
                //console.log('Response:', response);
                //check if the callback is valid before executing it
                if (typeof callback === 'function' && (i === (minerKeyArray.length - 1))) {
                    callback();
                }
            });
            reqArr.shift();
        });
    });
};
//undo the route we set
var unsetWithdrawVestingRoute = function(callback) {
    //fill in required miner arrays
    var reqArr = [];
    //prompt the user for their destination wallet and the percentile
    //from
    reqArr.push(dst);
    //cancel withdraw route
    reqArr.push(0);
    //auto_vest
    reqArr.push(false);
    //broadcast
    reqArr.push(true);
    //for each miner name, call set_withdraw_vesting_route
    //should be using rpc call get_account to verify account names
    minerAccountArray.forEach((acc, i) => {
        reqArr.unshift(acc);
        client.request('set_withdraw_vesting_route', reqArr, rpcIDs.setWithdrawVestingRouteID + i, function(err, response) {
            if (err) {
                console.log('An error with unset_withdraw_vesting_route has occured');
                throw err;
            }
            //check if the callback is valid before executing it
            if (typeof callback === 'function' && (i === (minerKeyArray.length - 1))) {
                callback();
            }
        });
        reqArr.shift();
    });
};
/*
gethelp import_key

Imports a WIF Private Key into the wallet to be used to sign transactions
by an account.

example: import_key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

Parameters:
wif_key: the WIF Private Key to import (type: string)
*/
var importMinerPrivateKeys = function(callback) {
    //take keys from minerKeyArray and import them via loop
    var i = 0;
    minerKeyArray.forEach((key, i) => {
        client.request('import_key', [key], rpcIDs.importMinerPrivateKeysID + i, function(err, response) {
            if (err) {
                console.log('An error with importMinerPrivateKeys has occured');
                throw err;
            }
            //console.log('Response: ', response);
            if (typeof callback === 'function' && (i === (minerKeyArray.length - 1))) {
                callback();
            }
        });
    });
};
/*
gethelp withdraw_vesting

Set up a vesting withdraw request. The request is fulfilled once a week
over the next two year (104 weeks).

Parameters:
from: The account the VESTS are withdrawn from (type: string)
vesting_shares: The amount of VESTS to withdraw over the next two
years. Each week (amount/104) shares are withdrawn and deposited
back as STEEM. i.e. "10.000000 VESTS" (type: asset)
broadcast: true if you wish to broadcast the transaction (type: bool)
*/
var withdrawVesting = function(callback) {
    //take keys from minerKeyArray and import them via loop
    helper.asyncLoop(minerAccountArray.length, function(loop) {
            var schema = {
                properties: {
                    VESTS: {
                        description: `How many VESTS would you like to powerdown from ${minerAccountArray[loop.iteration()]}?\n`,
                        type: 'string',
                        required: true
                    }
                }
            };

            prompt.get(schema, function(err, response) {
                response.VESTS = response.VESTS + ".000000 VESTS";
                client.request('withdraw_vesting', [minerAccountArray[loop.iteration()], response.VESTS, true], rpcIDs.withdrawVestingID + loop.index, function(err, response) {
                    if (err) {
                        console.log('An error with withdrawVesting has occured');
                        throw err;
                    }
                    if (typeof callback === 'function' && (loop.iteration() === (minerAccountArray.length - 1))) {
                        callback();
                    } else {
                        loop.next();
                    }
                });
            });
        },
        function() {}
    );
};
/*
gethelp list_my_accounts

Gets the account information for all accounts for which this wallet has a
private key
*/
var listMyAccounts = function(callback) {
    client.request('list_my_accounts', [], rpcIDs.listMyAccountsID, function(err, response) {
        if (err) {
            console.log("An error with list_my_accounts has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        console.log("\nHere are your accounts and their SteemPower values:");
        for (var i in response.result) {
            var curr = response.result[i];
            console.log(`   ${curr.name}:	${curr.balance}
			              ${parseInt(curr.vesting_shares)*steemPowerRatio}
	                  ${curr.sbd_balance}\n`);
        }
        if (typeof callback === 'function') {
            callback();
        }
    });
};
/*
gethelp unlock

Unlocks the wallet.

The wallet remain unlocked until the 'lock' is called or the program exits.

Parameters:
password: the password previously set with 'set_password()' (type:
string)
*/
//unlock(true, set_password, import)
var unlockWallet = function(callback) {
    //call is_locked, then if it is locked prompt user for password
    var schema = {
        properties: {
            password: {
                description: 'Your wallet is locked, please enter your password to unlock it\n',
                type: 'string',
                hidden: true,
                replace: '*',
                required: true
            }
        }
    };
    prompt.start();
    prompt.get(schema, function(err, result) {
        if (err) {
            console.log("Password prompt error");
            throw err;
        }
        client.request('unlock', [result.password], rpcIDs.unlockWalletID, function(err, response) {
            if (err) {
                console.log("An error with unlock has occured");
                throw err;
            }
            //console.log("Unlock result: " + response.result);
            if (typeof callback === 'function') {
                callback(response.result);
            }
        });
    });
};

/*
gethelp set_password

Sets a new password on the wallet.

The wallet must be either 'new' or 'unlocked' to execute this command.

*/
var setWalletPass = function(isNew, callback) {
    //prompt user for a password and verify it
    //need to check state of the wallet, if it is new or not first
    //before we prompt the user to set a password
    if (isNew !== true) {
        return;
    }
    var passGood = false;
    var schema = {
        properties: {
            password: {
                description: 'Please enter a password for your wallet:\n',
                type: 'string',
                hidden: true,
                replace: '*',
                required: true
            },
            verify: {
                description: 'Please enter in your password again:\n',
                type: 'string',
                hidden: true,
                replace: '*',
                required: true
            }
        }
    };
    prompt.start();
    //while (passGood === false) {
    prompt.get(schema, function(err, result) {
        if (err) {
            console.log("Password prompt error");
            throw err;
        }
        if (result.password !== result.verify) {
            console.log("Passwords do not match");
        } else {
            passGood = true;
            client.request('set_password', [result.password], rpcIDs.setWalletPassID, function(err, response) {
                if (err) {
                    console.log("An error with set_password has occured");
                    throw err;
                }
                //console.log("set_password result: " + response.result);
                //check if the callback is valid before executing it
                if (typeof callback === 'function') {
                    callback();
                }
            });
        }
    });
    //  }
};

/*gethelp is_locked

Checks whether the wallet is locked (is unable to use its private keys).

This state can be changed by calling 'lock()' or 'unlock()'.

Returns
true if the wallet is locked
*/
var isLocked = function(callback) {
    //use for checking if wallet is locked before performing any actions
    client.request('is_locked', [], rpcIDs.isLockedID, function(err, response) {
        if (err) {
            console.log("An error with is_locked has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        //console.log("isLocked Return result:" + response.result);
        //if the wallet is locked === true
        if (typeof callback === 'function') {
            callback(response.result);
        }
    });
};

var isNew = function(callback) {
    client.request('is_new', [], rpcIDs.isNewID, function(err, response) {
        if (err) {
            console.log("An error with is_new has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        //  console.log("isNew Return result: " + response.result);
        if (typeof callback === 'function') {
            callback(response.result);
        }
    });
};
//setWithdrawVestingRoute();
//Some function for importing all of the miner keys and accounts into cli_wallet, then locking them via user password
//then we will be able to use setWithdrawVestingRoute()

//allow user to modify miners, modify witnesses automatically

var modifyMinerandWitnesses = function(err, rawContents, callback) {
    if (minerAccountArray.length > 0) {
        console.log("\nHere are your current accounts and their corrsponding keys: ");
        for (i = 0; i < minerAccountArray.length; i++) {
            console.log("   Account " + i + ": " + minerAccountArray[i] + ", Key " + i + ": " + minerKeyArray[i]);
        }
    } else {
        console.log("No accounts found");
    }
    var actionSchema = {
        properties: {
            actionChoice: {
                description: '\n Would you like to: \n 1)  Add \n 2)  Remove \n 0)  Exit \n An account?\n'.magenta,
                pattern: /([0-2])/,
                type: 'integer',
                required: true
            },
            //need to perform additional checks on addAcc
            addAcc: {
                description: '\nEnter the account name you want to add:\n',
                type: 'string',
                ask: function() {
                    //only ask for account name if '1' was selected
                    return prompt.history('actionChoice').value === 1;
                },
                required: true
            },
            //need to perform additional checks on addkey
            addKey: {
                description: 'Enter the account private key you want to add:\n',
                type: 'string',
                ask: function() {
                    //only ask for account key if '1' was selected
                    return prompt.history('actionChoice').value === 1;
                },
                required: true
            },
            remove: {
                description: '\nEnter the account number you want to remove:\n',
                type: 'integer',
                ask: function() {
                    //only ask for account removal if '2' was selected
                    return prompt.history('actionChoice').value === 2;
                },
                required: true
            },
        }
    };
    prompt.start();
    prompt.get(actionSchema, function(err, result) {
        //user has selected to exit
        if (result.actionChoice === 0) return;
        var lines = rawContents.split(/\n/);
        //user has selected to add an entry
        if (result.actionChoice === 1) {

            //parse through the array and find the start of witnesses or miners in config
            for (var line in lines) {
                if (lines[line].match(/^# witness =/)) {
                    //add to the witnesses one line ahead of #witness
                    lines.splice(parseInt(line) + 1, 0, `witness = \"${result.addAcc}\"`);
                }
                if (lines[line].match(/^# miner =/)) {
                    //add to the miners one line ahead of #miners
                    var accArr = [`[\"${result.addAcc}\",\"${result.addKey}\"]`];
                    lines.splice(parseInt(line) + 1, 0, "miner = " + accArr);
                }
            }
            //join the entire array into a string, replacing each seperator with \n
            var modifiedConfig = lines.join("\n");
            fs.writeFile(steemConf, modifiedConfig, 'utf8', function(err) {
                if (err) {
                    console.log("An error with modifyMinerandWitnesses has occured");
                    throw err;
                }
                if (typeof(callback) === 'function') callback();
            });
        }

        //they have selected the remove option
        else {
            //parse through the array until we match a line with their selected account name
            //this regex will also match the witness with the same name and remove it too
            var witness = 'witness = \"' + minerAccountArray[result.remove].toString();
            var miner = 'miner = \\[\\"' + minerAccountArray[result.remove].toString();
            for (var lineToRemove in lines) {
                if (lines[lineToRemove].match(witness) || lines[lineToRemove].match(miner)) {
                    //instead of actually deleting the entry, we comment it out just incase it was accidental
                    lines[lineToRemove] = "#REMOVED " + lines[lineToRemove];
                }
            }
            //join the entire array into a string, replacing each seperator with \n
            var cutConfig = lines.join("\n");
            fs.writeFile(steemConf, cutConfig, 'utf8', function(err) {
                if (err) {
                    console.log("An error with modifyMinerandWitnesses has occured");
                    throw err;
                }
                if (typeof(callback) === 'function') callback();
            });
            //add in exit function
        }
    });
};

//Calls info in cli_wallet and uses info to find conversion Ratio for Vests -> STEEM
var getRatio = function(callback) {
    client.request('info', [], rpcIDs.infoID, function(err, response) {
        if (err) {
            console.log("An error with info has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        //cut off non-number text and convert to numbers
        var steem = parseInt(response.result.total_vesting_fund_steem);
        var vests = parseInt(response.result.total_vesting_shares);
        steemPowerRatio = steem / vests;
        return callback();
    });
};

var autowithdraw = function(callback) {
    isNew((newBool) => {
        //if wallet is new
        if (newBool === true) {
            return setWalletPass(newBool, () => {
                return unlockWallet(() => {
                    return _autoWithdrawHelper(callback);
                });
            });
        }
        //if wallet is false
        else {
            isLocked((locked) => {
                if (locked === true) {
                    return unlockWallet(() => {
                        return _autoWithdrawHelper(callback);
                    });
                } else {
                    return _autoWithdrawHelper(callback);
                }
            });
        }
    });
};

var _autoWithdrawHelper = function(callback) {
    return importMinerPrivateKeys(() => {
        return setWithdrawVestingRoute(() => {
            return getRatio(() => {
                return listMyAccounts(() => {
                    return withdrawVesting(() => {
                        return unsetWithdrawVestingRoute(callback);
                    });
                });
            });
        });
    });
};

//export object encapsulating the functions required for ezWalletMenu.js
var exportFuncs = {
    getSteemConfFile: getSteemConfFile,
    getMinerInfo: getMinerInfo,
    modifyMinerandWitnesses: modifyMinerandWitnesses,
    autowithdraw: autowithdraw,
};

module.exports = exportFuncs;
