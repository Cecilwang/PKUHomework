var debug = require('debug')('ets:getAllTaskDet');
var usr = require('../modules/UserSchema.js');
var config = require('../config');
var Task = require('../modules/TaskSchema.js');
var toolbox = require('../modules/toolbox.js');


Task.find({},
    function(err, doc) {
        doc.forEach(function(item) {
            if (item.remindertime != null)
                item.remindertime = item.remindertime.split('/').join('-');
            if (item.ddl != null)
                item.ddl = item.ddl.split('/').join('-');
            if (item.donetime != null)
                item.donetime = item.donetime.split('/').join('-');
            item.save();
        });
    });
