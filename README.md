# AppSync WebSockets With Apollo (iOS) v1+

## Introduction

This is a sample implementation for Apollo iOS and AWS AppSync that works for real-time GraphQL endpoints.

The Apollo iOS Documentation is a good starting point when integrating AWS AppSync Graphql endpoints, but it falls a bit short when it comes to integrating a real-time endpoint.

## Compatibility

- Apollo iOS v1+

## Implementation

Specific customisations need to be made for the real-time / `WebSocket` implementation to work.

- **Server Protocol**
  - `AppSync`'s server protocol adheres to `graphql-ws`
- **Custom URL Format**
  - For `API key` or `Lambda authorization` a custom header / payload format is required
  - See more on [required header parameter formats based on AWS AppSync API authorization mode](https://docs.aws.amazon.com/appsync/latest/devguide/real-time-websocket-client.html#header-parameter-format-based-on-appsync-api-authorization-mode)
- **Request Body Format**
  - The request body format needs to be converted to what is expected by `AppSync`
    - `AppSync` expects:
      ```
      {
          "id": "subscriptionId",
          "type": "start",
          "payload":
          {
              "data":
              {
                  "query": "query string",
                  "variables": "variables"
              },
              "extensions":
              {
                  "authorization":
                  {
                      "host": "host",
                      "x-api-key": "apikey"
                  }
              }
          }
      }
      ```
    - `Apollo iOS`, by default, provides:
      ```
      {
          "id": "subscriptionId",
          "type": "start",
          "payload":
          {
              "variables": "variables",
              "extensions": "extensions",
              "operationName": "subscriptionName",
              "query": "query string"
          }
      }
      ```
