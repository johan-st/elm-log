const uuid = require('uuid');
const chalk = require('chalk');

const logger = logs => (req, res, next) => {
  req.id = uuid.v4();

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

  console.log(
    chalk.grey(req.id),
    method,
    chalk.green(req.path),
    req.body,
    req.query
  );

  next();
};

module.exports = { logger };
