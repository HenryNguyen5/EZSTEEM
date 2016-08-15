var ezWallet = require("./ezWallet.js");
var prompt = require("./node_modules/prompt");

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
	}
	//grab the miner's info from config.ini
	ezWallet.getSteemConfFile(ezWallet.getMinerInfo);
//TODO loop the prompt somehow
		prompt.start();
		prompt.get(schema, function(err, result) {
			if (result.choice === 0) process.exit();
			if (result.choice === 1) {
				ezWallet.getSteemConfFile(ezWallet.modifyMinerandWitnesses);
			}
			if (result.choice === 2) {
				// Awaiting finishes to ezWallet.js
			};
		});

}

runMenu();
