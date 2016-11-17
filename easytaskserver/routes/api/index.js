config = require('../../config.js');

const routes = require('express').Router();

const version = require('./'+config.version);

routes.use(version);

module.exports = routes;
