//getalltask
var debug = require('debug')('ets:getFinishTaskDet');
var usr = require('../../../modules/UserSchema.js');
var config = require('../../../config');
var Task = require('../../../modules/TaskSchema.js');
var toolbox = require('../../../modules/toolbox.js');

module.exports = function(req, res) {
    if (typeof(req.body.uid) == 'undefined' || !req.body.uid) {
        debug('No uid provided');
        return res.status(412).json({
            success: false,
            message: 'require uid'
        });
    }

    debug('uid : ' + req.body.uid);

    Task.find({
            belong: req.body.uid,
            teamtask: 0,
            status: 1
        },
        function(err, doc) {
            if (err) {
                debug(err);
                return res.status(500).json({
                    success: false,
                    message: err
                });
            } else {
                var output = 'tid :';
                doc.forEach(function(item) {
                    output = output + ' ' + item.tid.toString();
                });
                debug(output);

                doc.sort(function(a,b){
                    var atime = toolbox.DateToInt(a.ddl);
                    var btime = toolbox.DateToInt(b.ddl);
                    if(atime < btime) return -1;
                    if(atime > btime) return 1;
                    if(a.priority > b.priority) return -1;
                    if(a.priority < b.priority) return 1;
                    return 0;
                });

                var out_task = [];
                doc.forEach(function(item) {
                    var one_task = {
                        tid: item.tid,
                        name: item.name,
                        ddl: item.ddl,
                        remindertime: item.remindertime,
                        priority: item.priority,
                        status: item.status,
                        belong: item.belong,
                        teamtask: item.teamtask,
                        donetime: item.donetime,
                        ddl_timestamp: toolbox.DateToInt(item.ddl),
                        remindertime_timestamp: toolbox.DateToInt(item.remindertime),
                        donetime_timestamp: toolbox.DateToInt(item.donetime)
                    }
                    out_task.push(one_task);
                });

                return res.status(200).json({
                    success: true,
                    task: out_task
                });
            }
        });
};
