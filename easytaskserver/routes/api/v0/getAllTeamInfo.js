var debug = require('debug')('ets:getAllTeaminfo');
var config = require('../../../config');
var User = require('../../../modules/UserSchema.js');
var toolbox = require('../../../modules/toolbox.js');
var Team = require('../../../modules/TeamSchema.js');

module.exports = function(req, res) {
    Team.find({
        'teamid': {
            $in: req.user.team
        }
    }, function(err, docs) {
        if (err) {
            debug(err);
            return res.status(500).json({
                success: false,
                message: err
            });
        } else {
            var out_team = [];
            docs.forEach(function(item) {
                var one_team = {
                    teamid: item.teamid,
                    name: item.name,
                    leader: item.leader,
                    member: item.member,
                    task: item.task
                }
                out_team.push(one_team);
            });

            return res.status(200).json({
                success: true,
                team: out_team
            });
        }

    });
};
