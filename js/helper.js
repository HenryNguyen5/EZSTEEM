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

var convertVESTS = function(steem, vests, ratio) {
    steem = steem.slice(0, -6);
    vests = vests.slice(0, -6);
    steem = parseInt(steem);
    vests = parseInt(vests);
    return 0;
};

module.exports = {
    asyncLoop: asyncLoop,
    convertVESTS: convertVESTS
};
