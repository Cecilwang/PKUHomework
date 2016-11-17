const debug = require('debug')('ets:route_index');
const routes = require('express').Router();

//---------------Login--------------------------------
const login = require('./login.js');
routes.post('/login', login);

//---------------Signup--------------------------------
const signup = require('./signup.js');
routes.post('/signup', signup);

//---------------Authenticate-------------------------
const authenticate = require('./authenticate.js');
routes.use(authenticate);

//---------------GetUserInfo-------------------------
const getUserInfo= require('./getUserInfo.js');
routes.post('/getUserInfo', getUserInfo);

//---------------ModifyUserInfo-------------------------
const modifyUserInfo= require('./modifyUserInfo.js');
routes.post('/modifyUserInfo', modifyUserInfo);

//---------------GetUserScore-------------------------
const getUserScore= require('./getUserScore.js');
routes.post('/getUserScore', getUserScore);

//---------------GetAllTeam-------------------------
const getAllTeam= require('./getAllTeam.js');
routes.post('/getAllTeam', getAllTeam);

//---------------GetManagedTeam-------------------------
const getManagedTeam= require('./getManagedTeam.js');
routes.post('/getManagedTeam', getManagedTeam);

//---------------GetTeamInfo-------------------------
const getTeamInfo= require('./getTeamInfo.js');
routes.post('/getTeamInfo', getTeamInfo);

//---------------CreateTeam-------------------------
const createTeam= require('./createTeam.js');
routes.post('/createTeam', createTeam);

//---------------JoinTeam-------------------------
const joinTeam= require('./joinTeam.js');
routes.post('/joinTeam', joinTeam);

//---------------LeaveTeam-------------------------
const leaveTeam= require('./leaveTeam.js');
routes.post('/leaveTeam', leaveTeam);

//---------------AddTask-------------------------
const addTask= require('./addTask.js');
routes.post('/addTask', addTask);

//---------------getTaskDet-------------------------
const getTaskDet= require('./getTaskDet.js');
routes.post('/getTaskDet', getTaskDet);

//---------------getAllTask-------------------------
const getAllTask= require('./getAllTask.js');
routes.post('/getAllTask', getAllTask);

//---------------finishTask-------------------------
const finishTask= require('./finishTask.js');
routes.post('/finishTask', finishTask);

//---------------giveupTask-------------------------
const giveupTask= require('./giveupTask.js');
routes.post('/giveupTask', giveupTask);

//---------------sortTask-------------------------
const sortTask= require('./sortTask.js');
routes.post('/sortTask', sortTask);

//---------------addTeamTask-------------------------
const addTeamTask= require('./addTeamTask.js');
routes.post('/addTeamTask', addTeamTask);

//---------------getAllTaskDet-------------------------
const getAllTaskDet= require('./getAllTaskDet.js');
routes.post('/getAllTaskDet', getAllTaskDet);

//---------------getRunningTaskDet-------------------------
const getRunningTaskDet= require('./getRunningTaskDet.js');
routes.post('/getRunningTaskDet', getRunningTaskDet);

//---------------getGiveUpTaskDet-------------------------
const getGiveUpTaskDet= require('./getGiveUpTaskDet.js');
routes.post('/getGiveUpTaskDet', getGiveUpTaskDet);

//---------------getFinishTaskDet-------------------------
const getFinishTaskDet= require('./getFinishTaskDet.js');
routes.post('/getFinishTaskDet', getFinishTaskDet);

//---------------getAllTeamInfo-------------------------
const getAllTeamInfo= require('./getAllTeamInfo.js');
routes.post('/getAllTeamInfo', getAllTeamInfo);

//---------------getAllTeamTask-------------------------
const getAllTeamTask= require('./getAllTeamTask.js');
routes.post('/getAllTeamTask', getAllTeamTask);

//---------------finishTeamTask-------------------------
const finishTeamTask= require('./finishTeamTask.js');
routes.post('/finishTeamTask', finishTeamTask);

//---------------giveupTeamTask-------------------------
const giveupTeamTask= require('./giveupTeamTask.js');
routes.post('/giveupTeamTask', giveupTeamTask);

//---------------modifyTask-------------------------
const modifyTask= require('./modifyTask.js');
routes.post('/modifyTask', modifyTask);

module.exports = routes;
