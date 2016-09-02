var asyncLoop = function(iterations, func, callback) {
    var index = 0;
    var done = false;
    var loop = {
        next: function() {
            if (done) {
                return;
            }
            if (iterations === -1) {
                func(loop);
            } else if (index < iterations) {
                index++;
                func(loop);
            } else {
                done = true;
                callback();
            }
        },
        iteration: function() {
            return index - 1;
        },
        break: function() {
            done = true;
            callback();
        }
    };
    loop.next();
    return loop;
};

//Takes current miner's VESTS and the VESTS -> STEEM ratio and outputs a clean string
var convertVests = function(vests, ratio) {
    //slice " VESTS" for conversion to number
    vests = parseInt(vests.slice(0,-6));
    //convert back to a string, append the unit type and return
    return toString(vests*ratio) + " STEEM";
};

module.exports = {
    asyncLoop: asyncLoop,
    convertVests: convertVests
};
