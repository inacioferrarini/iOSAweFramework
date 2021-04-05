//    The MIT License (MIT)
//
//    Copyright (c) 2020 Inácio Ferrarini
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

///
/// Basic Api class.
///
/// Handles remote HTTP requests using Apple APIs.
///
open class API {

    ///
    /// Supported Http Methods
    ///
    public enum HttpMethod: String {
        ///
        /// HTTP GET
        ///
        case get = "GET"

        ///
        /// HTTP POST
        ///
        case post = "POST"

        ///
        /// HTTP PUT
        ///
        case put = "PUT"

        ///
        /// HTTP PATCH
        ///
        case patch = "PATCH"

        ///
        /// HTTP DELETE
        ///
        case delete = "DELETE"

    }

    ///
    /// Supported Network Errors
    ///
    public enum NetworkError: Error {

        ///
        /// Error happened while trying to decode given data to the given type.
        ///
        case decodingError

        ///
        /// Data returned from the backend was not properly parsed to given type.
        ///
        case domainError

        ///
        /// Internet is absent
        ///
        case noInternet
    }

    // MARK: - Properties

    let rootUrl: String

    // MARK: - Initialization

    ///
    /// Inits the class using the given the root url.
    ///
    /// - parameter rootUrl: The  server base url.
    ///
    public init(_ rootUrl: String) {
        self.rootUrl = rootUrl
    }

    // MARK: - Supporting methods

    ///
    /// Performs a httpMethod kind request to the given path.
    /// If the requests succeeds, the `completion` block will be called after converting the result
    /// using the given transformer.
    /// If the request fails, the 'errorHandler' block will be called instead.
    ///
    /// - parameter httpMethod: Http method to execute.
    ///
    /// - parameter _: The server base url. If `nil`, `rootUrl` will be used.
    ///
    /// - parameter targetUrl: The request path.
    ///
    /// - parameter requestObject: Request object with values to be used as body.
    ///
    /// - parameter requestHeaders: Http Headers to be sent with the request.
    ///
    /// - parameter completionHandler: the block to be called when the request completes.
    ///
    /// - parameter retryAttempts: How many tries before calling `errorHandler` block.
    ///
    open func executeRequest<RequestType, ResponseType>(
        httpMethod: API.HttpMethod,
        _ endpointUrl: String? = nil,
        targetUrl: String,
        requestObject: RequestType? = nil,
        requestHeaders: [String: String]? = nil,
        completionHandler: @escaping ((Result<ResponseType, Error>) -> Void),
        retryAttempts: Int) where RequestType: Encodable, ResponseType: Decodable {

        var requestData: Data = Data()
        requestData <-- requestObject

        executeRequest(httpMethod: httpMethod,
                       endpointUrl,
                       targetUrl: targetUrl,
                       requestData: requestData,
                       requestHeaders: requestHeaders,
                       completionHandler: completionHandler,
                       retryAttempts: retryAttempts)
    }

    ///
    /// Performs a httpMethod kind request to the given path.
    /// If the requests succeeds, the `completion` block will be called after converting the result
    /// using the given transformer.
    /// If the request fails, the 'errorHandler' block will be called instead.
    ///
    /// - parameter httpMethod: Http method to execute.
    ///
    /// - parameter _: The server base url. If `nil`, `rootUrl` will be used.
    ///
    /// - parameter targetUrl: The request path.
    ///
    /// - parameter requestData: Request data to be used as body.
    ///
    /// - parameter requestHeaders: Http Headers to be sent with the request.
    ///
    /// - parameter completionHandler: the block to be called when the request completes.
    ///
    /// - parameter retryAttempts: How many tries before calling `errorHandler` block.
    ///
    open func executeRequest<ResponseType>(
        httpMethod: API.HttpMethod,
        _ endpointUrl: String? = nil,
        targetUrl: String,
        requestData: Data? = nil,
        requestHeaders: [String: String]? = nil,
        completionHandler: @escaping ((Result<ResponseType, Error>) -> Void),
        retryAttempts: Int) where ResponseType: Decodable {

        let endpointUrl = endpointUrl ?? self.rootUrl
        let urlString = endpointUrl + targetUrl
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: urlString) else { return }

        let requestBody = self.requestBody(httpMethod: httpMethod,
                                           url: url,
                                           requestData: requestData,
                                           requestHeaders: requestHeaders)

        let dataTask = defaultSession.dataTask(with: requestBody) { (data, _, error) in
            if let error = error {
                if retryAttempts <= 1 {
                    completionHandler(.failure(error))
                } else {
                    self.executeRequest(httpMethod: httpMethod,
                                        endpointUrl,
                                        targetUrl: targetUrl,
                                        requestData: requestData,
                                        requestHeaders: requestHeaders,
                                        completionHandler: completionHandler,
                                        retryAttempts: retryAttempts - 1)
                }
            } else {
                var response: ResponseType?
                if let data = data {
                    if let strData = String(data: data, encoding: .utf8) {
                        debugPrint("--> response: \(strData)")
                    }
                    response <-- data
                }
                if let response = response {
                    DispatchQueue.main.async {
                        completionHandler(.success(response))
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(NetworkError.decodingError))
                    }
                }
            }
        }

        dataTask.resume()
    }

    ///
    /// Assembles a URLRequest using given values.
    ///
    /// - parameter httpMethod: Http method to execute.
    ///
    /// - parameter url: The url request.
    ///
    /// - parameter requestObject: Request object with values to be used as body.
    ///
    /// - parameter requestHeaders: Http Headers to be sent with the request.
    ///
    func requestBody(
        httpMethod: HttpMethod,
        url: URL,
        requestData: Data? = nil,
        requestHeaders: [String: String]? = nil) -> URLRequest {

        var requestBody = URLRequest(url: url)
        requestBody.httpMethod = httpMethod.rawValue
		requestBody.httpBody = nil
		if httpMethod != .get {
			requestBody.httpBody = requestData
		}

        if let requestHeaders = requestHeaders {
            for headerField in requestHeaders.keys {
                guard let value = requestHeaders[headerField] else { continue }
                requestBody.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        return requestBody
    }

}
