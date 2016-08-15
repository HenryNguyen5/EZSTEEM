var ezWallet = require("./ezWallet.js");
var prompt = require("./node_modules/prompt");

console.log("----------\nezWallet\n----------");

var runMenu = function() {
	var schema = {
		properties: {
			choice: {
				description: "Would you like to:\n" +
					     "1) View or modify your miner entries\n" +
				    	     "2) Transfer your mined SteemPower to a main account\n" +
					     "  NOTE: This will transfer the same percentage of Steempower\n    " +
					     "from every single one of your miners to your main account!\n" +
					     "0) Exit",
				pattern: /([0-2])/,
				required: true
			}
		}
	}

	prompt.start();
	prompt.get(schema, function(err, result) {
		if (result.choice === '1') {
			ezWallet.getSteemConfFile(ezWallet.getMinerInfo);
			ezWallet.getSteemConfFile(ezWallet.modifyMinerandWitnesses);
		}
		if (result.choice === '2') {
			//awaiting finishes to ezWallet.js
		}
		else {
			return;
		}
	});
}

runMenu();
