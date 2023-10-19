import Apollo
import ApolloAPI
import Foundation

/*
 Generates a request body that conforms to the expected AppSync payload format
  {
      data: {
          query: string josnstring base64
          variables: object optional
      }
      extension: {
          authorization: object optional
      }
  }
 */

enum PayloadKey: String {
    case data
    case query
    case variables
    case extensions
    case authorization
}

class AppSyncRequestBodyCreator: RequestBodyCreator {
    init(_ authorization: [String: String]) {
        self.authorization = authorization
    }

    private var authorization: [String: String]

    public func requestBody<Operation>(for operation: Operation, sendQueryDocument: Bool, autoPersistQuery: Bool) -> JSONEncodableDictionary where Operation: GraphQLOperation {
        var body: JSONEncodableDictionary = [:]

        var dataInfo: [String: Any] = [:]

        if let variables = operation.__variables {
            dataInfo[PayloadKey.variables.rawValue] = variables
        }

        if sendQueryDocument {
            guard let document = Operation.definition?.queryDocument else {
                preconditionFailure("To send query documents, Apollo types must be generated with `OperationDefinition`s.")
            }
            dataInfo[PayloadKey.query.rawValue] = document
        }

        // The data portion of the body needs to have the query and variables as well.
        guard let data = try? JSONSerialization.data(withJSONObject: dataInfo, options: .prettyPrinted) else {
            fatalError("Somehow the query and variables aren't valid JSON!")
        }

        let jsonString = String(data: data, encoding: .utf8)

        body[PayloadKey.data.rawValue] = jsonString

        if autoPersistQuery {
            guard let operationIdentifier = Operation.operationIdentifier else {
                preconditionFailure("To enable `autoPersistQueries`, Apollo types must be generated with operationIdentifiers")
            }

            body[PayloadKey.extensions.rawValue] = [
                "persistedQuery": ["sha256Hash": operationIdentifier, "version": 1],
                PayloadKey.authorization.rawValue: [
                    authKey: authValue,
                    hostKey: hostValue,
                ],
            ]
        } else {
            body[PayloadKey.extensions.rawValue] = [
                PayloadKey.authorization.rawValue: [
                    authKey: authValue,
                    hostKey: hostValue,
                ],
            ]
        }

        return body
    }
}
