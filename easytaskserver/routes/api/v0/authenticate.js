var jwt = require('jsonwebtoken');
var debug = require('debug')('ets:authenticate');
var config = require('../../../config');
var User = require('../../../modules/UserSchema.js');

module.exports = function(req, res, next) {
    //check req's content
    if (typeof(req.body) == 'undefined' || !req.body) {
        debug('No body provided');
        return res.status(412).json({
            success: false,
            message: 'require body'
        });
    }

    if (typeof(req.body.uid) == 'undefined' || !req.body.uid) {
        debug('No uid provided');
        return res.status(412).json({
            success: false,
            message: 'require uid'
        });
    }

    var token = req.body.token || req.query.token || req.headers['x-access-token'];
    if (!token) {
        debug('No token provided');
        return res.status(412).json({
            success: false,
            message: 'require token'
        });
    }

    debug('uid: [%d]', req.body.uid);
    // check the user exist
    User.findOne({
        uid: req.body.uid
    }, function(err, doc) {
        if (err) {
            debug(err);
            return res.status(500).json({
                success: false,
                message: err
            });
        } else if (doc == null) {
            debug('the user doesnt exist');
            return res.status(400).json({
                success: false,
                message: 'the user doesnt exist'
            });
        } else {
            debug('DEBUG : ' + config.DEBUG);
            if (config.DEBUG) {
                req.user = doc;
                next();
            } else {
                // verifies secret and checks exp
                debug('token : [%s]', token);
                jwt.verify(token, config.secret, function(err, decoded) {
                    if (err) {
                        debug('Token verify Error: ' + err.message);
                        return res.status(401).json({
                            success: false,
                            message: 'Failed to authenticate token. ' + err.message
                        });
                    } else if (req.body.uid != decoded.uid) {
                        debug('user and token dose not match');
                        return res.status(401).json({
                            success: false,
                            message: 'user and token dose not match'
                        });
                    } else {
                        // if everything is good, save to request for use in other routes
                        debug('successful authentication');
                        req.user = doc;
                        next();
                    }
                });
            }
        }
    });
};
