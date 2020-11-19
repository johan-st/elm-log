const express = require('express');
const router = express.Router();
const chalk = require('chalk');
const data = require('./data');
const logs = data.logs();
const Log = logs.model('Log', {
  log: String,
  updated: { type: Date, default: Date.now },
});

router.post('*', (req, res) => {
  const log = new Log({ log: req.body.log });
  res.status = 200;
  log.save().then(e => res.json(e));
});

module.exports = { router };
