cordova = require('cordova');
exec = require('cordova/exec');


function MicrophoneLevels() {
    this.cordova = null;
}

MicrophoneLevels.prototype.start = function() {
    exec(null, onError, "MicrophoneLevels", "start", null);
};

MicrophoneLevels.prototype.stop = function() {
    exec(null, onError, "MicrophoneLevels", "stop", null);
};

MicrophoneLevels.prototype.levels = function() {
    exec(onLevels, onError, "MicrophoneLevels", "levels", null);
};

var onLevels = function(params) {
    console.log(params);
}

var onError = function(err) {
    console.log("Error");
    console.log(err);
};

module.exports = new MicrophoneLevels();