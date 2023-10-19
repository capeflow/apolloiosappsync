import Apollo
import ApolloAPI
import Foundation

class AuthorizationInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        request.addHeader(name: "<custom>", value: "<custom>")
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
