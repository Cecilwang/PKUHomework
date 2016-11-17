var jwt = require('jsonwebtoken');
var debug = require('debug')('ets:login');
var config = require('../../../config');
var User = require('../../../modules/UserSchema.js');

module.exports = function(req, res) {

    //check req's content
    //Caution: the res'method is asynchronous
    if(typeof(req.body) == 'undefined' || !req.body) {
        debug('No body provided');
        return res.status(412).json({
            success: false,
            message: 'require name and password'
        });
    }

    if (typeof(req.body.name) == 'undefined' || !req.body.name) {
        debug('No name provided');
        return res.status(412).json({
            success: false,
            message: 'require name'
        });
    }

    if (typeof(req.body.password) == 'undefined' || !req.body.password) {
        debug('No password provided');
        return res.status(412).json({
            success: false,
            message: 'require password'
        });
    }

    //display req content
    debug('name : [%s]', req.body.name);
    debug('password : [%s]', req.body.password);

    //find user
    //Caution: nodejs is asynchronous
    User.findOne({name: req.body.name}, function(err, doc){
        // database error
        if(err){
            debug(err);
            return res.status(500).json({
                success: false,
                message: err
            });
        }
        // find the User
        if(doc){
            debug('User : '+JSON.stringify(doc));
            if(req.body.password == doc.password) {
                var token = jwt.sign({uid:doc.uid}, config.secret, {
                    expiresIn: config.expireTime
                });
                return res.status(200).json({
                    success: true,
                    uid: doc.uid,
                    token: token
                });
            }else{
                debug('Invaild Password');
                return res.status(401).json({
                  success: false,
                  message: 'Your user name/ password combination was not correct. Please try again'
                });
            }
        } else { // cannot find user by name
           debug('Cannot find user by name');
           return res.status(404).json({
               success: false,
               message: 'Cannot find user by name'
           });
        }
    });

};
