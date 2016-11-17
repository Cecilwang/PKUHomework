//add task
var debug = require('debug')('ets:addTeamTask');
var task = require('../../../modules/TaskSchema.js');
var user = require('../../../modules/UserSchema.js');
var config = require('../../../config');
var toolbox = require('../../../modules/toolbox.js');
var Team = require('../../../modules/TeamSchema.js');

module.exports = function(req, res) {
    if (typeof(req.body.name) == 'undefined' || !req.body.name) {
        debug('No name provided');
        return res.status(412).json({
            success: false,
            message: 'require name'
        });
    }
    if (typeof(req.body.ddl) == 'undefined' || !req.body.ddl) {
        debug('No ddl provided');
        return res.status(412).json({
            success: false,
            message: 'require ddl'
        });
    }
    if (typeof(req.body.teamid) == 'undefined' || !req.body.teamid) {
        debug('No teamid provided');
        return res.status(412).json({
            success: false,
            message: 'require teamid'
        });
    }
    /*
    if(typedof(req.body.tasktype)=='undefined'||!req.body.tasktype){
        dubug('No tasktype provided');
        return res.status(412).json({
            success:false,
            message:'require tasktype'
        });
    }
    if(typedof(req.body.remindertime)=='undefined'||!req.body.remindertime){
        debug('No remindertime provided');
        return res.status(412).json({
            success:false,
            message:'require remindertime'
        });
    }
    if(typedof(req.body.priority)=='undefined'||!req.body.priority){
        debug('No priority provided');
        return res.status(412).json({
            success:false,
            message:'require priority'
        });
    }
    */
    debug('teamid : ' + req.body.teamid);
    debug('name:[%s]', req.body.name);
    debug('ddl:[%s]', req.body.ddl);
    //debug('tasktype:[%d]',req.body.tasktype);
    debug('remindertime:[%s]', req.body.remindertime);
    if (req.body.priority == null)
        req.body.priority = 0;
    debug('priority:[%d]', req.body.priority);

    debug('user manage team : ' + req.user.managedteam);
    if (toolbox.IsInArray(req.user.managedteam, req.body.teamid) == false) {
        debug('user dosent manage this team')
        return res.status(400).json({
            success: false,
            message: 'you dont manage this team'
        })
    }
    debug('user manage this team');

    var new_team_task = {
        name: req.body.name,
        ddl: req.body.ddl,
        priority: req.body.priority,
        status: 0,
        belong: req.body.teamid,
        teamtask: 1,
        donetime:null
    };
    if (req.body.remindertime != null)
        new_team_task.remindertime = req.body.remindertime;
    else {
        new_team_task.remindertime = null;
    }

    debug('Team Task : ' + JSON.stringify(new_team_task));

    task.create(new_team_task, function(err, doc) {
        if (err) {
            debug('Can not creat team task : ' + err);
            return res.status(500).json({
                success: false,
                message: 'Can not creat team task' + err
            });
        } else {
            debug('Creat team task : tid [%d] _id [%s]', doc.tid, doc._id);

            Team.update({
                teamid: req.body.teamid
            }, {
                $push: {
                    task: doc.tid
                }
            }, function(err) {
                // database error
                if (err) {
                    debug(err);
                    return res.status(500).json({
                        success: false,
                        message: err
                    });
                } else {
                    return res.status(200).json({
                        success: true,
                        tid: doc.tid
                    });
                }
            });
        }
    });
}
