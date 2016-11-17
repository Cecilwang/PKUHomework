var debug = require('debug')('ets:db:team');
var mongoose = require('mongoose');
var autoIncrement = require('mongoose-auto-increment');
var config = require('../config.js');

var connection = mongoose.createConnection(config.database, {keepAlive: 1});
autoIncrement.initialize(connection);

connection.on('error', console.error.bind(console, 'Can not connect to Team Database'));
connection.once('open', function(){
    debug('Connect to Team Database');
});

var TeamSchema = mongoose.Schema({
    teamid: {type: Number, unique: true},
    name: {type: String},
    leader : Number,
    task: [Number],
    member: [Number]
});

TeamSchema.plugin(autoIncrement.plugin, {model:'Team', field:'teamid'});

TeamSchema.statics.AddExample = function(){
    var example = {
        name : 'cecilssdgsw'
    };
    this.create(example, function(err, doc){
        if (err) {
            debug('Can not creat example Team : ' + err);
        } else {
            debug('Creat example Team : teamid [%d] _id [%s]', doc.teamid, doc._id);
        }

    });
};

var Team = connection.model('Team', TeamSchema);

//Team.AddExample();

module.exports = Team;
