import Apollo
import ApolloAPI
import ApolloWebSocket
import Foundation

// MARK: Input variables

let hostKey = "host"
let hostValue = "<custom>.appsync-api.us-east-2.amazonaws.com"

let authKey = "<custom>" /// i.e. "x-api-key", "Authorization"
let authValue = "<custom>" /// i.e. "da2-<custom>", "Bearer <token>"

let normalEndPoint = "https://<custom>.appsync-api.us-east-2.amazonaws.com/graphql"
let realtimeEndPoint = "wss://<custom>.appsync-realtime-api.us-east-2.amazonaws.com/graphql"

// MARK: Network implementation

class Network {
    static let shared = Network()

    private(set) lazy var apollo: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: normalEndPoint)!
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)
        let wsUrl = generateWebSocketURL()
        let webSocket = WebSocket(
            url: wsUrl,
            protocol: .graphql_ws
        )
        let requestBody = AppSyncRequestBodyCreator([authKey: authValue])
        let webSocketTransport = WebSocketTransport(websocket: webSocket, config: WebSocketTransport.Configuration(requestBodyCreator: requestBody))
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )

        return ApolloClient(networkTransport: splitTransport, store: store)
    }()

    /// Generate the required endpoint URL format for the websocket connection.
    /// See more here
    /// https://docs.aws.amazon.com/appsync/latest/devguide/real-time-websocket-client.html#header-parameter-format-based-on-appsync-api-authorization-mode

    private func generateWebSocketURL() -> URL {
        let authDict = [
            authKey: authValue,
            hostKey: hostValue,
        ]

        let headerData: Data = try! JSONSerialization.data(withJSONObject: authDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let headerBase64 = headerData.base64EncodedString()

        let payloadData = try! JSONSerialization.data(withJSONObject: [:], options: JSONSerialization.WritingOptions.prettyPrinted)
        let payloadBase64 = payloadData.base64EncodedString()

        let url = URL(string: realtimeEndPoint + "?header=\(headerBase64)&payload=\(payloadBase64)")!

        return url
    }
}
