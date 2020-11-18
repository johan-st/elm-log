const { env } = require('process');
const MongoClient = require('mongodb').MongoClient;

const connect = (client, collName) =>
  new Promise((resolve, reject) => {
    client.connect(err => {
      const collection = client.db('logs').collection(collName);
      if (err) err => ({ statusCode: 500, body: err.toString() });
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
      resolve(collection);
    });
  });

const handler = async event => {
  process.setMaxListeners(15);
  env.NETLIFY_DEV ? (collName = 'dev') : (collName = 'general');
  console.log(collName);
  const uri = `mongodb+srv://${env.MONGODB_USER}:${env.MONGODB_PW}@cluster0.nq5ro.mongodb.net/logs?retryWrites=true&w=majority`;
  const client = await new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  if (event.httpMethod === 'POST') {
    console.log('POST', event.httpMethod);
    connect(client, collName)
      .then(collection => {
        console.log(collection);
        res = collection.insertOne(JSON.parse(event.body));
        return {
          statusCode: 202,
          body: JSON.stringify(
            {
              handler: env._HANDLER,
              action: 'inserting log',
              collection: collName,
              body: event.body,
              event,
            },
            null,
            4
          ),
        };
      })
      .catch(err => ({
        statusCode: 500,
        body: JSON.stringify(
          {
            handler: env._HANDLER,
            action: 'log inserted',
            collection: collName,
            query: event.queryStringParameters.q,
            event,
          },
          null,
          4
        ),
      }));
  } else if (event.httpMethod === 'GET') {
    console.log('GET', event.httpMethod);
    connect(client, collName)
      .then(collection => {
        console.log(collection);
        res = collection.find(event.body);
        return {
          statusCode: 202,
          body: JSON.stringify(
            {
              handler: env._HANDLER,
              action: 'log inserted',
              collection: collName,
              query: event.queryStringParameters.q,
              event,
            },
            null,
            4
          ),
        };
      })
      .catch(err => ({
        statusCode: 500,
        body: JSON.stringify(
          {
            handler: env._HANDLER,
            action: 'log inserted',
            collection: collName,
            query: event.queryStringParameters.q,
            event,
          },
          null,
          4
        ),
      }));
  } else {
    return {
      statusCode: 500,
      body: JSON.stringify(
        {
          handler: env._HANDLER,
          result: 'error',
          event,
        },
        null,
        4
      ),
    };
  }
};

module.exports = { handler };
