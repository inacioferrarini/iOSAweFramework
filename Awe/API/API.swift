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
    /// - parameter headers: Http Headers to be sent with the request.
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
        headers: [String: String]? = nil,
        completionHandler: @escaping ((Result<ResponseType?, Error>) -> Void),
        retryAttempts: Int) where RequestType: Encodable, ResponseType: Decodable {

        let endpointUrl = endpointUrl ?? self.rootUrl
        let urlString = endpointUrl + targetUrl
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        guard let url = URL(string: urlString) else { return }

        let requestBody = self.requestBody(httpMethod: httpMethod,
                                           url: url,
                                           requestObject: requestObject,
                                           headers: headers)

        let dataTask = defaultSession.dataTask(with: requestBody) { (data, _, error) in
            if let error = error {
                if retryAttempts <= 1 {
                    completionHandler(.failure(error))
                } else {
                    self.executeRequest(httpMethod: httpMethod,
                                        endpointUrl,
                                        targetUrl: targetUrl,
                                        requestObject: requestObject,
                                        headers: headers,
                                        completionHandler: completionHandler,
                                        retryAttempts: retryAttempts - 1)
                }
            } else {
                var response: ResponseType?
                if let data = data {
                    response <-- data
                }
                DispatchQueue.main.async {
                    completionHandler(.success(response))
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
    /// - parameter headers: Http Headers to be sent with the request.
    ///
    func requestBody<RequestType>(
        httpMethod: HttpMethod,
        url: URL,
        requestObject: RequestType? = nil,
        headers: [String: String]? = nil) -> URLRequest where RequestType: Encodable {

        var requestBody = URLRequest(url: url)
        requestBody.httpMethod = httpMethod.rawValue

        var data: Data = Data()
        data <-- requestObject
        requestBody.httpBody = data

        if let headers = headers {
            for headerField in headers.keys {
                guard let value = headers[headerField] else { continue }
                requestBody.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        return requestBody
    }

}
