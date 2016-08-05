var jayson = require('./node_modules/jayson');
var prompt = require('./node_modules/prompt');
var fs = require('fs');
//create a client to interact with cli_wallet
var client = jayson.client.http('http://127.0.0.1:8090');
//client.options.version = 1;
console.log(client);
var isLocked = function() {
    //use for checking if wallet is locked before performing any actions
    client.request('get_block', [1], 1, function(err, response) {
        if (err) {
            console.log("An error with is_locked has occured: SHOULD NOT HAPPEN EVER");
            throw err;
        }
	console.log(response);
	for (var key in response.result){
	console.log("Results:" + response.result[key]);
}
       // console.log("isLocked Return result:" + response.result);
        return response.result;
    });
};
isLocked();
