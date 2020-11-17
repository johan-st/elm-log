// Docs on event and context https://www.netlify.com/docs/functions/#the-handler-method
const handler = async event => {
  try {
    return {
      statusCode: 200,
      body: JSON.stringify(
        {
          path: event.path,
          method: event.httpMethod,
          body: event.body,
          queries: event.queryStringParameters,
          ip: event.headers['client-ip'],
        },
        null,
        4
      ),
    };
  } catch (error) {
    return { statusCode: 500, body: error.toString() };
  }
};

module.exports = { handler };
