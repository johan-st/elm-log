require('dotenv').config();
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const { logger } = require('./logger');
const path = require('path');
const { env } = process;
const chalk = require('chalk');
const port = env.EXPRESS_PORT;
const logsRouter = require('./logsRouter').router;

app.use('/static', express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());

app.use(logger);

app.use('/logs', logsRouter);

app.listen(port, () => {
  console.log(chalk.green(`[Express]`), chalk.grey('listening to port'), port);
});
