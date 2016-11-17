var debug = require('debug')('ets:getTeamInfo');
var config = require('../../../config');
var Team = require('../../../modules/TeamSchema.js');
var User = require('../../../modules/UserSchema.js');
var toolbox = require('../../../modules/toolbox.js');

module.exports = function(req, res) {
    //check whether req contains teamid
    if (typeof(req.body.teamid) == 'undefined' || !req.body.teamid) {
        debug('No teamid provided');
        return res.status(412).json({
            success: false,
            message: 'require teamid'
        });
    }

    debug('user has joined team : ' + req.user.team);
    if (toolbox.IsInArray(req.user.team, req.body.teamid) == false) {
        debug('user hasnt joined this team')
        return res.status(400).json({
            success: false,
            message: 'you havent joined this team'
        })
    }
    debug('user has joined this team');

    //fing the Team
    Team.findOne({
            teamid: req.body.teamid
        },
        function(err, doc) {
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
                    teamid: doc.teamid,
                    name: doc.name,
                    member: doc.member,
                    leader: doc.leader,
                    task: doc.task
                });
            }
        });
};
