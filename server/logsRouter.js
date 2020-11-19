const express = require('express');
const router = express.Router();

const logsRouter = logHub => {
  // OPERATIONS
  const postLog = (req, res) => {
    const log = new logHub({ data: req.body.data });
    res.status = 200;
    log.save().then(data => res.json({ result: [data] }));
  };

  const getLogs = (req, res) => {
    if (req.query.q) {
      logHub
        .find({ data: { $regex: req.query.q, $options: 'i' } })
        .then(data => {
          res.status = 200;
          res.json({ query: req.query.q, result: data });
        });
    } else {
      logHub.find({}).then(logHub => {
        res.status = 200;
        res.json({ result: logHub });
      });
    }
  };

  // ROUTES
  router.get('/', getLogs);
  router.post('/', postLog);
  return router;
};
module.exports = { logsRouter };
