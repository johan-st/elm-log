const uuid = require('uuid');
const chalk = require('chalk');

const logger = logs => (req, res, next) => {
  req.id = uuid.v4();
  const id = chalk.grey(req.id);
  const query = req.query;
  const body = req.body;
  const path = chalk.green(req.path);

  let method;
  switch (req.method) {
    case 'POST':
      method = chalk.red(req.method);
      break;
    case 'GET':
      method = chalk.blue(req.method);
      break;
    default:
      method = req.method;
      break;
  }

  const log = new logs({
    type_: 'request',
    data: {
      id: req.id,
      method: req.method,
      path: req.path,
      query,
      body,
    },
  });
  // log.save();
  if (log.data.path === '/logs') {
    console.log(id, method, path, body, query);
    log.save();
    next();
  }
};

module.exports = { logger };
