const uuid = require('uuid');
const chalk = require('chalk');

const logger = logHub => (req, res, next) => {
  req.id = uuid.v4();
  const query = req.query;
  const body = req.body;

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

  const log = new logHub({
    logType: 'HTTP_request',
    data: {
      id: req.id,
      method: req.method,
      path: req.path,
      body: req.body,
      query: req.query,
    },
  });
  console.log(
    chalk.grey(req.id),
    method,
    chalk.green(req.path),
    req.body,
    req.query
  );
  // log.save();
  next();
  // }
};

module.exports = { logger };
