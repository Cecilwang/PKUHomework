var debug = require('debug')('ets:createTeam');
var User = require('../../../modules/UserSchema.js');
var Team = require('../../../modules/TeamSchema.js');

module.exports = function(req, res) {
    debug('create team');
    var new_team = {
        member: [req.body.uid],
        leader: req.body.uid
    };
    if (req.body.name)
        new_team.name = req.body.name;
    else{
        new_team.name = null;
    }

    debug('Team : '+JSON.stringify(new_team));

    Team.create(new_team, function(err, doc) {
        if (err) {
            debug('Can not creat team : ' + err);
            return res.status(500).json({
                success: false,
                message: 'Can not creat team' + err
            });
        } else {
            debug('Creat team : teamid [%d] _id [%s]', doc.teamid, doc._id);

            //fix: team maybe have same value. should use the funciton like addtoset?
            User.update({
                uid: req.body.uid
            }, {
                $push: {
                    team: doc.teamid,
                    managedteam: doc.teamid
                }
            }, function(err) {
                if (err) {
                    //fix: should delete the new_team
                    debug(err);
                    return res.status(500).json({
                        success: false,
                        message: err
                    });
                } else {
                    debug('Update user and return response');
                    return res.status(200).json({
                        success: true,
                        teamid: doc.teamid
                    });
                }
            });
        }
    });
};
