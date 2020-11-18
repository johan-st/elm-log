const { env } = require('process');
const MongoClient = require('mongodb').MongoClient;

const test = require('assert');

const connect = async () => {
  env.NETLIFY_DEV ? (collName = 'dev') : (collName = 'general');
  const uri = `mongodb+srv://${env.MONGODB_USER}:${env.MONGODB_PW}@cluster0.nq5ro.mongodb.net/logs?retryWrites=true&w=majority`;
  return new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
};
const handler = async event => {
  try {
    const client = await connect();
    const query = event.queryStringParameters.q || env.MONGODB_USER;
    return {
      statusCode: 200,
      body: JSON.stringify({ user: `${query}` }),
    };
  } catch (error) {
    return { statusCode: 500, body: error.toString() };
  }
};

module.exports = { handler };
