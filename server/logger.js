const uuid = require('uuid');
const chalk = require('chalk');

const logger = (req, res, next) => {
  req.id = uuid.v4();
  console.log(
    chalk.grey(req.id),
    chalk.magenta(req.method),
    chalk.green(req.path),
    chalk.white(JSON.stringify(req.body, null, 0))
  );
  next();
};

module.exports = { logger };
