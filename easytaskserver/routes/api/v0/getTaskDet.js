//get details
var debug = require('debug')('ets:getTaskDet');
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
            } else {
                return res.status(200).json({
                    success: true,
                    tid: doc.tid,
                    name: doc.name,
                    ddl: doc.ddl,
                    remindertime: doc.remindertime,
                    priority: doc.priority,
                    status: doc.status,
                    belong: doc.belong,
                    teamtask: doc.teamtask,
                    donetime: doc.donetime
                });
            }
        });
};
