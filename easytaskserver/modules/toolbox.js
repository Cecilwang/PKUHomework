var debug = require('debug')('ets:toolbox');
var moment = require('moment');

module.exports.IsInArray = function(arr, obj) {
    if (!arr) return false;
    for (var i = 0; i < arr.length; ++i) {
        if (arr[i] == obj) {
            return true;
        }
    }
    return false;
}

module.exports.Remove = function(arr, obj) {
    if (!arr) return -1; //fix : arr is not a array
    for (var i = 0, n = 0; i < arr.length; i++) {
        if (arr[i] != obj) {
            arr[n++] = arr[i];
        }
    }
    arr.length = n;
}

module.exports.DateToInt = function(date) {
  return moment(date, "YYYY-MM-DD hh:mm a").unix();
}

module.exports.Now2String = function() {
  return moment().format("YYYY-MM-DD hh:mm a");
}
