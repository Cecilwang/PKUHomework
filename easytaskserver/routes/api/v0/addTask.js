//add task
var debug = require('debug')('ets:addTask');
var task = require('../../../modules/TaskSchema.js');
var user = require('../../../modules/UserSchema.js');
var config = require('../../../config');

module.exports = function(req, res){
    if(typeof(req.body.name)=='undefined' || !req.body.name){
        debug('No name provided');
        return res.status(412).json({
            success:false,
            message:'require name'
        });
    }
    if(typeof(req.body.ddl)=='undefined' || !req.body.ddl){
        debug('No ddl provided');
        return res.status(412).json({
            success:false,
            message:'require ddl'
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
    debug('name:[%s]',req.body.name);
    debug('ddl:[%s]',req.body.ddl);
    //debug('tasktype:[%d]',req.body.tasktype);
    debug('remindertime:[%s]',req.body.remindertime);
    if (req.body.priority == null)
      req.body.priority = 0;
    debug('priority:[%d]',req.body.priority);

    var new_task = {
        name:req.body.name,
        ddl:req.body.ddl,
        priority:req.body.priority,
        status:0,
        belong:req.body.uid,
        teamtask:0,
        donetime:null
    };
    if (req.body.remindertime != null )
      new_task.remindertime = req.body.remindertime;
    else {
      new_task.remindertime = null;
    }

    debug('Task : '+JSON.stringify(new_task));

    task.create(new_task, function(err, doc) {
        if (err) {
            debug('Can not creat task : ' + err);
            return res.status(500).json({
                success: false,
                message: 'Can not creat task' + err
            });
        } else {
            debug('Creat task : tid [%d] _id [%s]', doc.tid, doc._id);

            req.user.task.push(doc.tid);
            req.user.save(function(err){
              if (err) {
                  //fix: should undo add task
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
};
