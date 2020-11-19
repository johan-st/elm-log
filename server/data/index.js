const { env } = process;
const chalk = require('chalk');
const mongoose = require('mongoose');

const uri = env.MONGODB_URI_LOCAL + '/log-hub';
const options = {
  auth: {
    authSource: 'admin',
  },
  user: env.MONGODB_USER_LOCAL,
  pass: env.MONGODB_PW_LOCAL,
  keepAlive: true,
  keepAliveInitialDelay: 300000,
  useNewUrlParser: true,
  useUnifiedTopology: true,
};
// console.log(chalk.white(uri));
// console.log(chalk.grey(JSON.stringify(options, null, 2)));

const logs = () => {
  console.log(
    chalk.yellow('[MongoDB]'),
    chalk.grey('Connecting to'),
    uri,
    chalk.grey('with'),
    options.user
  );

  mongoose.connect(uri, options).catch(err => {
    console.log(chalk.red('- connection error -'));
  });

  mongoose.connection.on('connected', () => {
    console.log(chalk.green('[MongoDB]'), chalk.grey('connected to '), uri);
  });

  // If the connection throws an error
  mongoose.connection.on('error', err => {
    console.log(chalk.red(err.name), err);
  });

  // When the connection is disconnected
  mongoose.connection.on('disconnected', () => {
    console.log(chalk.cyan('[MongoDB]'), 'connection disconnected');
  });

  process.on('SIGINT', () => {
    mongoose.connection.close(() => {
      console.log(
        chalk.cyan('[MongoDB]'),
        'App terminated, closing mongo connections'
      );
      process.exit(0);
    });
  });
  return mongoose;
};

module.exports = { logs };
