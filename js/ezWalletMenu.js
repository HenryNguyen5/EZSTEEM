var ezWallet = require("./ezWallet.js");
var prompt = require("./node_modules/prompt");
var helper = require("./helper.js");

console.log(`
----------
ezWallet
----------
`);

var desc = `Would you like to:
1) View or modify your miner entries
2) Transfar your mined SteemPower to a main account
	NOTE: This will transfer the same percentage of Steempower
	      from every single one of your miners to your main account!
0) Exit`;

var runMenu = function() {
    //prompt the user
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
    //grab the miner's info from config.ini
    prompt.start();

    helper.asyncLoop(-1, function(loop) {
	ezWallet.getSteemConfFile(ezWallet.getMinerInfo);
    	prompt.get(schema, function(err, result) {
            if (result.choice === 0) loop.break();
            if (result.choice === 1) {
		ezWallet.getSteemConfFile(function(err, rawContents){
  		    return ezWallet.modifyMinerandWitnesses(err,rawContents,loop.next);
	    });
       	    }
            if (result.choice === 2) {
//            	ezWallet.autowithdraw();
            }
        })},
	function () { console.log("end") }
    );
};

runMenu();
