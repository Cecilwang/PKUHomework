var debug = require('debug')('decrypt');

module.exports = function(req, res, next) {
    debug('decrypt');
    next();
};
