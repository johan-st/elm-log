const { env } = process;
const { connect } = require('./connection');
const logSchema = require('./schemas/log');

const Log = async () =>
  await connect(
    env.MONGO_ATLAS_URI,
    env.MONGO_AMITY_LOGREADER_USER,
    env.MONGO_AMITY_LOGREADER_PW,
    'admin',
    'Log',
    logSchema
  );

module.exports = { Log };
