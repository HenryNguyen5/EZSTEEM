//This is a javascript wrapper for steem cli_wallet
//Usage: node ezWallet.js
//ORDER OF EXCECUTION:is_locked->set_password->unlock->getSteemConfFile->importMinerPrivateKeys->set_withdraw_vesting_route

var jayson = require('./node_modules/jayson');
var prompt = require('./node_modules/prompt');
var fs = require('fs');
var rpcIDs = {
    getWithdrawVestingRouteID: 1,
    setWalletPassID: 2,
    importMinerPrivateKeysID: 3,
    unlockWalletID: 4,
    isLockedID: 5,
    isNewID: 6
};
//create a client to interact with cli_wallet
var client = jayson.client.http('http://127.0.0.1:8090');
var minerAccountArray = [];
var minerKeyArray = [];
var steemConf = "";

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
            if (lines[line].match("/myConfigFile/")) {
                steemConf = lines[line].split('=')[1];
            }
        }
        console.log("steemconf:" + steemConf);
        return fs.readFile(steemConf, 'utf8', callback);
    });
};
getSteemConfFile(getMinerInfo);
//fill in the miners names and keys
var getMinerInfo = function(err, rawContents) {
    if (err) {
        console.log("An error has occured with getMinerInfo");
        throw err;
    }
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
    console.log(accKeyArr);
    //Seperate NAME and KEY into their respective arrays, minerAccountArray and minerKeyArray
    for (i = 0; i < accKeyArr.length; i++) {
        if (i % 2 === 0) {
            minerAccountArray.push(accKeyArr[i]);
        } else {
            minerKeyArray.push(accKeyArr[i]);
        }
    }
    console.log(minerAccountArray);
    console.log(minerKeyArray);
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
var getWithdrawVestingRoute = function() {
    //fill in required miner arrays
    var reqArr = [];
    //prompt the user for their destination wallet and the percentile
    var schema = {
        properties: {
            dst: {
                description: 'Which account do you want to transfer all of your miner accounts SteemPower to?',
                type: 'string',
                required: true
            },
            percent: {
                description: 'What percentage of the SteemPower mined would you like to send? (1-100)%',
                type: 'integer',
                required: true,
                before: function(value) {
                    return value * 100;
                }
            }
        }
    };
    prompt.start();
    prompt.get(schema, function(err, result) {
        for (var results in result) {
            reqArr.push(result[results]);
            console.log(result[results]);
        }
        reqArr.push(false);
        reqArr.push(true);
    });

    //for each miner name, call set_withdraw_vesting_route
    //possible change: allow user to select what miners to transfer their steem power
    //instead of automatically looping through all accounts
    //(or give both options)
    //should be using rpc call get_account to verify account names
    var batch = [];
    for (i = 0; i < minerAccountArray.length; i++) {
        reqArr.unshift(minerAccountArray[i]);
        batch.push(client.request('set_withdraw_vesting_route', reqArr, getWithdrawVestingRouteID + i));
        reqArr.shift();
    }

    client.request(batch, function(err, errors, successes) {
        if (err) {
            console.log('An error with set_withdraw_vesting_route has occured');
            throw err;
        }
        console.log('Errors', errors);
        console.log('successes', successes);
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
var importMinerPrivateKeys = function() {
    //take keys from minerKeyArray and import them via loop
    var batch = [];
    for (var key in minerKeyArray) {
        batch.push(client.request('import_key', [minerKeyArray[key]], importMinerPrivateKeysID + key));
    }
    client.request(batch, function(err, errors, successes) {
        if (err) {
            console.log('An error with importMinerPrivateKeys has occured');
            throw err;
        }
        console.log('Errors', errors);
        console.log('successes', successes);
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
var unlockWallet = function(locked) {
    //call is_locked, then if it is locked prompt user for password
    if (!locked) return;
    var schema = {
        properties: {
            password: {
                description: 'Your wallet is locked, please enter your password to unlock it',
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
        console.log(result.password);
        client.request('unlock', [result.password], unlockWalletID, function(err, response) {
            if (err) {
                console.log("An error with unlock has occured");
                throw err;
            }
            console.log("Unlock result: " + response.result);
        });
    });
};

/*
gethelp set_password

Sets a new password on the wallet.

The wallet must be either 'new' or 'unlocked' to execute this command.

*/
var setWalletPass = function(isNew) {
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
                description: 'Please enter a password for your wallet: ',
                type: 'string',
                hidden: true,
                replace: '*',
                required: true
            },
            verify: {
                description: 'Please enter in your password again: ',
                type: 'string',
                hidden: true,
                replace: '*',
                required: true
            }
        }
    };
    prompt.start();
    while (passGood === false) {
        prompt.get(schema, function(err, result) {
            if (err) {
                console.log("Password prompt error");
                throw err;
            }
            if (result.password !== result.verify) {
                console.log("Passwords do not match");
            } else {
                passGood = true;
                client.request('set_password', [result.password], setWalletPassID, function(err, response) {
                    if (err) {
                        console.log("An error with set_password has occured");
                        throw err;
                    }
                    console.log("set_password result: " + response.result);
                });
            }
        });
    }
};

/*gethelp is_locked

Checks whether the wallet is locked (is unable to use its private keys).

This state can be changed by calling 'lock()' or 'unlock()'.

Returns
true if the wallet is locked
*/
var isLocked = function(callback) {
    //use for checking if wallet is locked before performing any actions
    client.request('is_locked', [], isLockedID, function(err, response) {
        if (err) {
            console.log("An error with is_locked has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        console.log("isLocked Return result:" + response.result);
        callback(response.result);
    });
};

var isNew = function(callback) {
    client.request('is_new', [], isNewID, function(err, response) {
        if (err) {
            console.log("An error with is_new has occured: SHOULD NOT HAPPEN");
            throw err;
        }
        console.log("isNew Return result: " + response.result);
        callback(response.result);
    });
};
//getWithdrawVestingRoute();
//Some function for importing all of the miner keys and accounts into cli_wallet, then locking them via user password
//then we will be able to use getWithdrawVestingRoute()

//allow user to modify miners, modify witnesses automatically
getSteemConfFile(modifyMinerandWitnesses);
var modifyMinerandWitnesses = function(err, rawContents) {
    console.log("Here are your current accounts and their corrsponding keys: ");
    for (i = 0; i < minerAccountArray.length; i++) {
        console.log("Account " + i + ": " + minerAccountArray + ", Key " + i + ": " + minerKeyArray);
    }
    var actionSchema = {
        properties: {
            actionChoice: {
                description: 'Would you like to: \n 1) Add \n 2) Remove \n 0) Exit \n An account? ',
                pattern: /([0-2])/,
                required: true
            },
            //need to perform additional checks on addAcc
            addAcc: {
                description: 'Enter the account name you want to add: ',
                type: 'string',
                ask: function() {
                    //only ask for account name if '1' was selected
                    return prompt.history('actionChoice').value === 1;
                },
                required: true
            },
            //need to perform additional checks on addkey
            addKey: {
                description: 'Enter the account private key you want to add: ',
                type: 'string',
                ask: function() {
                    //only ask for account key if '1' was selected
                    return prompt.history('actionChoice').value === 1;
                },
                required: true
            },
            remove: {
                description: 'Enter the account number you want to remove: ',
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
                if (lines[line].match(/^# witness = /)) {
                    //add to the witnesses one line ahead of #witness
                    lines.splice(line + 1, 0, 'witness = ' + result.addAcc);
                }
                if (lines[line].match(/^# miner = /)) {
                    //add to the miners one line ahead of #miners
                    var accArr = ["\"" + result.addAcc + "\",\"" + result.addKey + "\""];
                    lines.splice(line + 1, 0, "miner = " + accArr);
                }
            }
            //join the entire array into a string, replacing each seperator with \n
            var modifiedConfig = lines.join("\n");
            fs.writeFile(steemConf, modifiedConfig, 'utf8', function(err) {
                if (err) {
                    console.log("An error with modifyMinerandWitnesses has occured");
                    throw err;
                }
            });
        }

        //they have selected the remove option
        else {
            //parse through the array until we match a line with their selected account name
            //this regex will also match the witness with the same name and remove it too
            for (var lineToRemove in lines) {
                if (lines[lineToRemove].match(minerAccountArray[result.remove])) {
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
            });
        }
    });
};
