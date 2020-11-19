require('dotenv').config();
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const { logger } = require('./logger');
const path = require('path');
const { env } = process;
const chalk = require('chalk');
const port = env.EXPRESS_PORT;
const { logsRouter } = require('./logsRouter');

require('./data')
  .logs()
  .then(logs => {
    // MIDDLEWARE
    app.use(bodyParser.json());
    app.use(logger(logs));

    // ROUTES
    app.use('/logs', logsRouter(logs));
    app.use(express.static('../build'));

    // SERVER INIT
    app.listen(port, () => {
      console.log(
        chalk.green(`[Express]`),
        chalk.grey('listening to port'),
        port
      );
    });
  })
  .catch(err => {
    console.log(chalk.red(err));
    process.exit(1);
  });
