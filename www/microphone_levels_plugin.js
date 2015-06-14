cordova = require('cordova');
exec = require('cordova/exec');
channels = require('cordova/channels');


function MicrophoneLevels() {
    this.cordova = null;
    this.channels = {
      	microphonelevels:cordova.addWindowEventHandler("microphonelevels")
    };
    for (var key in this.channels) {
        this.channels[key].onHasSubscribersChange = MicrophoneLevels.onHasSubscribersChange;
    }
};
/**
 * Event handlers for when callbacks get registered.
 * Keep track of how many handlers we have so we can start and stop the native microphone listener
 * appropriately.
 */
MicrophoneLevels.onHasSubscribersChange = function() {
  	// If we just registered the first handler, make sure native listener is started.
  	if (this.numHandlers === 1 && handlers() === 1) {
      	exec(microphoneLevels.onLevels, microphonelevels.onError, "MicrophoneLevels", "start", []);
  	} 
  	else if (handlers() === 0) {
      	exec(null, null, "MicrophoneLevels", "stop", []);
  	}
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