var jwt = require('jsonwebtoken');
var debug = require('debug')('ets:modifyUserInfo');
var config = require('../../../config');
var User = require('../../../modules/UserSchema.js');

module.exports = function (req, res) {
    //check whether req contains uid
    if (typeof(req.body.uid) == 'undefined' || !req.body.uid) {
        debug('No uid provided');
        return res.status(412).json({
            success: false,
            message: 'require uid'
        });
    }

    //fing the user
    User.findOne(
        {uid: req.body.uid},
        function (err, doc) {
            // database error
            if(err) {
                debug(err);
                return res.status(500).json({
                    success: false,
                    message: err
                });
            }
            else {
                User.update(
                    {uid: req.body.uid},
                    {$set:
                        {name: req.body.name,
                            password: req.body.password,
                            tasktype: req.body.tasktype}
                    },
                    function(err) {
                        if (err) {
                            debug(err);
                            return res.status(500).json({
                                success: false,
                            });
                        }
                        debug("modify user: "+req.body.uid);
                    }
                );
                return res.status(200).json({
                    success: true,
                });
            }
        });
};
