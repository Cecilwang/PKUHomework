var debug = require('debug')('ets:joinTeam');
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
    if (toolbox.IsInArray(req.user.team, req.body.teamid) == true) {
        debug('user has joined this team')
        return res.status(400).json({
            success: false,
            message: 'you have joined this team'
        });
    }
    debug('user hasnt joined this team');

    //fix: Sometime the previous operation failed, the database maybe is
    //incorrect, so we should check the database(the uid has added to the
    //member), or add the validation
    Team.update({
        teamid: req.body.teamid
    }, {
        $push: {
            member: req.body.uid
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
            req.user.team.push(req.body.teamid);
            req.user.save(function(err) {
                if (err) {
                    //fix: should undo the team member
                    debug(err);
                    return res.status(500).json({
                        success: false,
                        message: err
                    });
                } else {
                    return res.status(200).json({
                        success: true
                    });
                }
            });
        }
    });
};
