var debug = require('debug')('ets:getAllTeamTask');
var usr = require('../../../modules/UserSchema.js');
var config = require('../../../config');
var Task = require('../../../modules/TaskSchema.js');
var toolbox = require('../../../modules/toolbox.js');
var Team = require('../../../modules/TeamSchema.js');

module.exports = function(req, res) {
    if (typeof(req.body.teamid) == 'undefined' || !req.body.teamid) {
        debug('No teamid provided');
        return res.status(412).json({
            success: false,
            message: 'require teamid'
        });
    }
    debug('teamid : ' + req.body.teamid);

    debug('user has joined team : ' + req.user.team);
    if (toolbox.IsInArray(req.user.team, req.body.teamid) == false) {
        debug('user hasnt joined this team')
        return res.status(400).json({
            success: false,
            message: 'you havent joined this team'
        });
    }
    debug('user has joined this team');

    Task.find({
            belong: req.body.teamid,
            teamtask: 1
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
                        donetime: item.donetime
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
