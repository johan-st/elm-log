const express = require('express');
const router = express.Router();

const logsRouter = logs => {
  // OPERATIONS
  const postLog = (req, res) => {
    const log = new logs({ log: req.body.data });
    res.status = 200;
    log.save().then(a => res.json(a));
  };

  const getLogs = (req, res) => {
    if (req.query.q) {
      logs.find({ data: { $regex: req.query.q, $options: 'i' } }).then(data => {
        res.status = 200;
        res.json({ query: req.query.q, result: data });
      });
    } else {
      logs.find({}).then(logs => {
        res.status = 200;
        res.json({ result: logs });
      });
    }
  };

  // ROUTES
  router.get('/', getLogs);
  router.post('/', postLog);
  return router;
};
module.exports = { logsRouter };
