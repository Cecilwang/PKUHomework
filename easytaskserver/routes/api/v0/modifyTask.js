var debug = require('debug')('ets:modifyTask');
var task = require('../../../modules/TaskSchema.js');
var config = require('../../../config');
var toolbox = require('../../../modules/toolbox.js');

module.exports = function(req, res) {
    if (typeof(req.body.tid) == 'undefined' || !req.body.tid) {
        debug('No tid provided');
        return res.status(412).json({
            success: false,
            message: 'require tid'
        });
    }

    debug('tid :　' + req.body.tid);

    if (toolbox.IsInArray(req.user.task, req.body.tid) == false) {
        debug('user dosent has this task')
        return res.status(400).json({
            success: false,
            message: 'you dont have  this task'
        });
    }
    debug('user has this task');

    task.findOne({
            tid: req.body.tid
        },
        function(err, doc) {
            if (err) {
                debug(err);
                return res.status(500).json({
                    success: false,
                    message: err
                });
            } else if (!doc) {
                debug('no such task');
                return res.status(400).json({
                    success: false,
                    message: 'no such task'
                });
            } else if (doc.status != 0) {
                debug('task is not running');
                return res.status(400).json({
                    success: false,
                    message: 'task is not running'
                });
            } else {
                if (req.body.ddl) {
                    debug('ddl : ' + req.body.ddl);
                    doc.ddl = req.body.ddl;
                }

                if (req.body.remindertime) {
                    debug('remindertime : ' + req.body.remindertime);
                    doc.remindertime = req.body.remindertime;
                }

                if (req.body.priority) {
                    debug('priority : ' + req.body.priority);
                    doc.priority = req.body.priority;
                }

                doc.save(function(err) {
                    if (err) {
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
};
