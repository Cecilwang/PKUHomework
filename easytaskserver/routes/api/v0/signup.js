var debug = require('debug')('ets:signup');
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
        if(doc){  //if the name has registered
            debug('find user : '+JSON.stringify(doc));
            debug('The name has registered');
            return res.status(400).json({
                success: false,
                message: 'The name has registered'
            });
        } else { // cannot find user by name
            debug('Begin registered');
            var new_user = {
                name: req.body.name,
                password: req.body.password,
                //task: null,
                //tasktype: null,
                score: 0,
                level: 1,
                //team: null,
                //managedteam: null
            };
            debug('new user info : '+ JSON.stringify(new_user));
            User.create(new_user, function(err, doc){
                if (err) {
                    debug('Can not creat user : ' + err);
                    return res.status(500).json({
                        success: false,
                        message: 'Can not creat user' + err
                    });
                } else {
                    debug('Creat user : uid [%d] _id [%s]', doc.uid, doc._id);
                    return res.status(200).json({
                        success: true,
                        uid: doc.uid
                    })
                }
            });
        }
    });

};
