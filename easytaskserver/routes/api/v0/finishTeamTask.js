var debug = require('debug')('ets:finishTeamTask');
var config = require('../../../config');
var Task = require('../../../modules/TaskSchema.js');
var User = require('../../../modules/UserSchema.js');
var toolbox = require('../../../modules/toolbox.js');
var Team = require('../../../modules/TeamSchema.js');

module.exports = function(req, res) {
    //check whether req contains tid
    if (typeof(req.body.tid) == 'undefined' || !req.body.tid) {
        debug('No tid provided');
        return res.status(412).json({
            success: false,
            message: 'require tid'
        });
    }

    Task.findOne({
        tid: req.body.tid
    }, function(err, doc) {
        // database error
        if (err) {
            debug(err);
            return res.status(500).json({
                success: false,
                message: err
            });
        }
        if (!doc) {
            debug('NO such task');
            return res.status(400).json({
                success: false,
                message: 'no such task'
            });
        } else {
            if (doc.status != 0) {
                debug('this task is not running');
                return res.status(400).json({
                    success: false,
                    message: 'this task is not running'
                });
            } else if (doc.teamtask == 0) {
                debug('this task belongs user');
                return res.status(400).json({
                    success: false,
                    message: 'this task belongs user'
                });
            } else {
                debug('this task belongs team');
                debug('task belongs team : ' + doc.belong);
                debug('user has team : ' + req.user.team);
                if (toolbox.IsInArray(req.user.team, doc.belong) == false) {
                    debug('user dosent has this team')
                    return res.status(400).json({
                        success: false,
                        message: 'you dont have this team'
                    });
                }
                debug('user has this team');

                doc.status = 1;
                doc.donetime = toolbox.Now2String();
                doc.save(function(err) {
                    if (err) {
                        debug(err);
                        return res.status(500).json({
                            success: false,
                            message: err
                        });
                    } else {
                        req.user.score = req.user.score + 1;
                        req.user.save(function(err) {
                            if (err) {
                                //fix: should undo the task member
                                debug(err);
                                return res.status(500).json({
                                    success: false,
                                    message: err
                                });
                            } else {
                                return res.status(200).json({
                                    success: true
                                });
                            }

                        });
                    }
                });
            }
        }
    });
};
