var debug = require('debug')('ets:db:user');
var mongoose = require('mongoose');
var autoIncrement = require('mongoose-auto-increment');
var config = require('../config.js');

var connection = mongoose.createConnection(config.database, {keepAlive: 1});
autoIncrement.initialize(connection);

connection.on('error', console.error.bind(console, 'Can not connect to User Database'));
connection.once('open', function(){
    debug('Connect to User Database');
});

var UserSchema = mongoose.Schema({
    uid: {type: Number, unique: true},
    name: {type: String, unique: true, require: true},
    password: {type: String, require: true},
    task: [Number],
    tasktype: [Number],
    score: Number,
    level: Number,
    team: [Number],
    managedteam: [Number]
});

UserSchema.plugin(autoIncrement.plugin, {model:'User', field:'uid'});

UserSchema.statics.AddExample = function(){
    var example = {
        name : 'cecilssdgsw',
        password : '1'
    };
    this.create(example, function(err, doc){
        if (err) {
            debug('Can not creat example user : ' + err);
        } else {
            debug('Creat example user : uid [%d] _id [%s]', doc.uid, doc._id);
        }

    });
};

var User = connection.model('User', UserSchema);

//User.AddExample();

module.exports = User;
