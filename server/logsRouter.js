const express = require('express');
const router = express.Router();
const chalk = require('chalk');

const errorHandler = (req, res, err) => {
  res.json({ ...err, ok: false }),
    console.log(
      chalk.red(req.id),
      chalk.redBright(err.codeName),
      chalk.grey(err)
    );
};

const logsRouter = logs => {
  // OPERATIONS
  // POST
  // const postLog = (req, res) => {
  //   const log = new logs({
  //     logType: req.body.type || 'generic',
  //     data: req.body.data,
  //   });
  //   res.status = 200;
  //   log
  //     .save()
  //     .then(data => res.json({ ok: true, data: [data] }))
  //     .catch(err => errorHandler(req, res, err));
  // };
  // GET
  const getLogs = (req, res) => {
    if (req.query.q) {
      logs
        .find({ data: { path: { $regex: req.query.q, $options: 'i' } } })
        .then(data => {
          res.status = 200;
          res.json({ ok: true, data: data });
          console.log(JSON.stringify(data[0], null, 2));
        })
        .catch(err => errorHandler(req, res, err));
    } else {
      logs
        .find({})
        .then(data => {
          res.status = 200;
          res.json({ ok: true, data: data });
        })
        .catch(err => errorHandler(req, res, err));
    }
  };

  // ROUTES
  router.get('/', getLogs);
  // router.post('/', postLog);
  return router;
};
module.exports = { logsRouter };
