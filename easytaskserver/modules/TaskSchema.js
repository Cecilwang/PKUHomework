var debug = require('debug')('ets:db:task');
var mongoose = require('mongoose');
var autoIncrement = require('mongoose-auto-increment');
var config = require('../config.js');


var connection = mongoose.createConnection(config.database, {
    keepAlive: 1
});
autoIncrement.initialize(connection);

connection.on('error', console.error.bind(console, 'Can not connect to Task Database'));
connection.once('open', function() {
    debug('Connect to Task Database');
});

var TaskSchema = mongoose.Schema({
    tid: {
        type: Number,
        unique: true
    },
    name: String,
    ddl: String,
    remindertime: String,
    tasktype: [Number],
    priority: Number,
    status: Number,
    belong: Number,
    teamtask: Number,
    donetime: String
});

TaskSchema.plugin(autoIncrement.plugin, {
    model: 'Task',
    field: 'tid'
});

TaskSchema.statics.AddExample = function() {
    var example = {
        name: 'example task'
    };
    this.create(example, function(err, doc) {
        if (err) {
            debug('Can not creat example task : ' + err);
        } else {
            debug('Creat example task : tid [%d] _id [%s]', doc.tid, doc._id);
        }
    });
};


var Task = connection.model('Task', TaskSchema);

//Task.AddExample();
module.exports = Task;
