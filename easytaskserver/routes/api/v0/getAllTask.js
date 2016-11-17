//getalltask
var debug = require('debug')('ets:getAllTask');
var usr = require('../../../modules/UserSchema.js');
var config = require('../../../config');

module.exports = function(req,res){
    if(typeof(req.body.uid) == 'undefined'||!req.body.uid){
        debug('No uid provided');
        return res.status(412).json({
            success:false,
            message:'require uid'
        });
    }

    debug('uid : ' + req.body.uid);

    usr.findOne(
        {uid:req.body.uid},
        function(err,doc){
        if(err){
            debug(err);
            return res.status(500).json({
                success:false,
                message:err
            });
        }
        else{
            return res.status(200).json({
                success:true,
                task:doc.task
            });
        }
    });
};
