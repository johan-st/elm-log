const { MongoClient } = require('mongodb');
const fetch = require('node-fetch');
const { env } = require('process');
const collName = env.NETLIFY_DEV ? 'dev' : 'general';

async function getData() {
  const uri = `mongodb+srv://${env.MONGODB_USER}:${env.MONGODB_PW}@cluster0.nq5ro.mongodb.net/logs?retryWrites=true&w=majority`;
  const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  console.log(uri);
  try {
    await client.connect();
    const test = await client
      .db('logs')
      .collection('dev')
      .findOne({ raw: 'env help me' });
    return test;
  } catch (err) {
    console.log(err); // output to netlify function log
  } finally {
    await client.close();
  }
}

const handler = async function (event, context) {
  try {
    const data = await getData();
    return {
      statusCode: 200,
      body: JSON.stringify(
        {
          handler: env._HANDLER,
          action: 'inserting log',
          collection: collName,
          data,
        },
        null,
        4
      ),
    };
  } catch (err) {
    console.log(err); // output to netlify function log
    return {
      statusCode: 500,
      body: JSON.stringify({ msg: err.message }),
    };
  }
};

module.exports = { handler };
