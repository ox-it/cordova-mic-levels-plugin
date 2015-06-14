cordova = require('cordova');
exec = require('cordova/exec');
channels = require('cordova/channels');


function MicrophoneLevels() {
    this.cordova = null;
    this.channels = {
      	microphonelevels:cordova.addWindowEventHandler("microphonelevels")
    };
};

MicrophoneLevels.prototype.start = function() {
    exec(null, onError, "MicrophoneLevels", "start", []]);
};

MicrophoneLevels.prototype.stop = function() {
    exec(null, onError, "MicrophoneLevels", "stop", []]);
};

MicrophoneLevels.prototype.levels = function() {
    exec(onLevels, onError, "MicrophoneLevels", "levels", []]);
};

var onLevels = function(params) {
    console.log(params);
    cordova.fireWindowEvent("microphonelevels", info);
}

var onError = function(err) {
    console.log("Error");
    console.log(err);
};

var microphoneLevels = new MicrophoneLevels();

module.exports = microphoneLevels;