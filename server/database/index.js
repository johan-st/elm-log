const { env } = process;
const chalk = require('chalk');
const mongoose = require('mongoose');

const uri = env.MONGO_URI;
const options = {
  auth: {
    authSource: 'log-hub',
  },
  user: env.MONGO_USER,
  pass: env.MONGO_PW,
  keepAlive: true,
  keepAliveInitialDelay: 300000,
  useNewUrlParser: true,
  useUnifiedTopology: true,
};
// console.log(chalk.white(uri));
// console.log(chalk.grey(JSON.stringify(options, null, 2)));

const logs = async () => {
  console.log(
    chalk.yellowBright('[MongoDB]'),
    chalk.yellow('Connecting to'),
    uri,
    chalk.yellow('with'),
    options.user
  );

  await mongoose.connect(uri, options).catch(err => {
    console.log(
      chalk.redBright('[MongoDB]'),
      chalk.red('- connection error -')
    );
    console.log(err);
    process.exit(1);
  });

  // TODO: why is this not printing?
  mongoose.connection.on('connected', () => {
    console.log(
      chalk.greenBright('[MongoDB]'),
      chalk.green('connected to '),
      uri
    );
  });

  // If the connection throws an error
  mongoose.connection.on('error', err => {
    console.log(chalk.red(err.name), err);
  });

  // When the connection is disconnected
  mongoose.connection.on('disconnected', () => {
    console.log(
      chalk.yellowBright('[MongoDB]'),
      chalk.yellow('connection disconnected')
    );
  });

  process.on('SIGINT', () => {
    mongoose.connection.close(() => {
      console.log(
        chalk.yellowBright('[MongoDB]'),
        chalk.yellow('App terminated, closing mongo connections')
      );
      process.exit(0);
    });
  });

  // SCHEMA
  return mongoose.model('Log', {
    logType: String,
    data: {},
    time: { type: Date, default: Date.now },
  });
};

module.exports = { logs };
