const { env } = require('process');
const MongoClient = require('mongodb').MongoClient;

const handler = async event => {
  process.setMaxListeners(15);
  let collName;
  env.NETLIFY_DEV ? (collName = 'dev') : (collName = 'prod');
  try {
    const uri = `mongodb+srv://${env.MONGODB_USER}:${env.MONGODB_PW}@cluster0.nq5ro.mongodb.net/logs?retryWrites=true&w=majority`;
    const client = new MongoClient(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    let res;
    if (event.httpMethod === 'post') {
      await client.connect(err => {
        if (err) err => ({ statusCode: 500, body: err.toString() });
        else {
          const general = client.db('logs').collection(collName);
          res = general.insertOne(JSON.parse(event.body));
          process.on('SIGINT', () => {
            console.log('SIGINT: closing mongodb connection');
            client.close;
          });
          process.on('SIGTERM', () => {
            console.log('SIGTERM: closing mongodb connection');
            client.close;
          });
          process.on('SIGSTOP', () => {
            console.log('SIGSTOP: closing mongodb connection');
            client.close;
          });
          process.on('SIGQUIT', () => {
            console.log('SIGQUIT: closing mongodb connection');
            client.close;
          });
          process.on('SIGBREAK', () => {
            console.log('SIGBREAK: closing mongodb connection');
            client.close;
          });
        }
      });
      return {
        statusCode: 200,
        body: JSON.stringify(
          {
            handler: env._HANDLER,
            result: 'log inserted',
            error: err.toString(),
            collection: collName,
            body: event.body,
            queries: event.queryStringParameters,
          },
          null,
          4
        ),
      };
    } else {
      await client.connect(err => {
        if (err) err => ({ statusCode: 500, body: err.toString() });
        else {
          const general = client.db('logs').collection(collName);
          res = general.insertOne(JSON.parse(event.body));
          process.on('SIGINT', () => {
            console.log('SIGINT: closing mongodb connection');
            client.close;
          });
          process.on('SIGTERM', () => {
            console.log('SIGTERM: closing mongodb connection');
            client.close;
          });
          process.on('SIGSTOP', () => {
            console.log('SIGSTOP: closing mongodb connection');
            client.close;
          });
          process.on('SIGQUIT', () => {
            console.log('SIGQUIT: closing mongodb connection');
            client.close;
          });
          process.on('SIGBREAK', () => {
            console.log('SIGBREAK: closing mongodb connection');
            client.close;
          });
        }
      });
      return {
        statusCode: 200,
        body: JSON.stringify(
          {
            handler: env._HANDLER,
            result: 'log inserted',
            collection: collName,
            body: event.body,
            queries: event.queryStringParameters,
          },
          null,
          4
        ),
      };
    }
  } catch (error) {
    console.log(res);
    return { statusCode: 500, body: error.toString() };
  }
};

module.exports = { handler };
