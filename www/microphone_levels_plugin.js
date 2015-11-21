cordova = require('cordova');
exec = require('cordova/exec');
channel = require('cordova/channel');


function MicrophoneLevels() {
    this.cordova = null;
    this.channels = {
          microphonelevels:cordova.addWindowEventHandler("microphonelevels")
    };
    for (var key in this.channels) {
      //  this.channels[key].onHasSubscribersChange = MicrophoneLevels.onHasSubscribersChange;
    }
    this.timer = null;
}

/**
 * Event handlers for when callbacks get registered.
 * Keep track of how many handlers we have so we can start and stop the native microphone listener
 * appropriately.
 */
MicrophoneLevels.onHasSubscribersChange = function() {
     // If we just registered the first handler, make sure native listener is started.
     if (this.numHandlers === 1 && this.handlers() === 1) {
          exec(microphoneLevels.onLevels, microphonelevels.onError, "MicrophoneLevels", "start", []);
     }
     else if (handlers() === 0) {
          exec(null, null, "MicrophoneLevels", "stop", []);
     }
};

MicrophoneLevels.prototype.start = function() {
    exec(null, onError, "MicrophoneLevels", "start", []);
    //startTimer
    this.timer = window.setInterval(this.levels, 0.01);
};

MicrophoneLevels.prototype.stop = function() {
    exec(null, onError, "MicrophoneLevels", "stop", []);
    //stopTimer
    window.clearInterval(this.timer);
};

MicrophoneLevels.prototype.levels = function() {
    exec(onLevels, onError, "MicrophoneLevels", "levels", []);
};

MicrophoneLevels.prototype.setLowShelfFilterFrequency = function(lowShelfFrequency) {
    exec(onFilters, onError, "MicrophoneLevels", "setLowShelfFilterFrequency", [lowShelfFrequency]);
};

MicrophoneLevels.prototype.setHighShelfFilterFrequency = function(highShelfFrequency) {
    exec(onFilters, onError, "MicrophoneLevels", "setHighShelfFilterFrequency", [highShelfFrequency]);
};


var onLevels = function(params) {
    console.log(params);
    cordova.fireWindowEvent("microphonelevels", params);
};

var onFilters = function(params) {
    console.log(params);
    cordova.fireWindowEvent("microphonefilters", params);
};

var onError = function(err) {
    console.log("Error");
    console.log(err);
};

module.exports = new MicrophoneLevels();