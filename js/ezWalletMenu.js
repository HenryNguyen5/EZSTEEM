/*jshint esversion: 6*/
var ezWallet = require("./ezWallet.js");
var prompt = require("./node_modules/prompt");
var helper = require("./helper.js");
var colors = require("colors");

//clear screen
console.log('\033[2J');

console.log(`
-----------------------------------------------------------
--------------------Welcome to ezWallet--------------------
-----------------------------------------------------------`.magenta);

console.log(`\n---------------------------Menu----------------------------`.magenta);

var desc = `\n What would you like to do today?

 1)  View or modify your miner entries
 2)  Transfer your miner's SteemPower to a single account
 0)  Exit

`.magenta;

var runMenu = function() {
    //prompt the user, 0-2 inclusive
    var schema = {
        properties: {
            choice: {
                description: desc,
                pattern: /([0-2])/,
                type: 'integer',
                required: true
            }
        }
    };
    prompt.message = "";
    prompt.delimiter = colors.magenta("Enter your choice here > ");
    prompt.start();

    helper.asyncLoop(-1, function(loop) {
            ezWallet.getSteemConfFile(ezWallet.getMinerInfo);
            prompt.get(schema, function(err, result) {
		//end program
                if (result.choice === 0) loop.break();
		//add, remove miners
                if (result.choice === 1) {
                    ezWallet.getSteemConfFile(function(err, rawContents) {
                        return ezWallet.modifyMinerandWitnesses(err, rawContents, loop.next);
                    });
                }
                if (result.choice === 2) {
		    //transfer vests
                    ezWallet.autowithdraw(loop.next);
                }
            });
        },
	//calls upon exit of program
        function() {
            console.log("end");
        }
    );
};

runMenu();
