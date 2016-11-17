//get details
var debug = require('debug')('ets:sortTask');
var task = require('../../../modules/TaskSchema.js');
var config = require('../../../config');
var toolbox = require('../../../modules/toolbox.js');

module.exports = function(req, res) {
    task.find({
            belong: req.body.uid,
            status: 0,
            teamtask: 0
        },
        function(err, doc) {
            if (err) {
                debug(err);
                return res.status(500).json({
                    success: false,
                    message: err
                });
            } else {
                var output = 'tid before sort :';
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
                var output = 'tid after sort :';
                doc.forEach(function(item) {
                  output = output + ' ' + item.tid.toString();
                });
                debug(output);
                var tid = [];
                doc.forEach(function(item) {
                    tid.push(item.tid);
                });
                debug('tid : ' + tid);
                return res.status(200).json({
                    success: true,
                    tid: tid,
                });
            }
        });
};
