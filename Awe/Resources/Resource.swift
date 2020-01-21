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

import Foundation

///
/// Represents an URL resource.
///
public struct Resource<T: Codable> {

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
    /// Resource URL to be used to load the resource.
    ///
    public var url: URL

    ///
    /// Data to be sent when loading the resource.
    ///
    public var body: Data?

    ///
    /// The Http method to be used when loading the resource.
    ///
    public var httpMethod: HttpMethod = .get

    ///
    /// Http Headers to be used when loading the resource.
    ///
    public var httpHeaders: [String: String] = [:]

}

extension Resource {

    public init(url: URL, body: Data? = nil) {
        self.url = url
        self.body = body
    }

    public init<T: Encodable>(url: URL, body: T? = nil) {
        self.url = url
        let body = try? JSONEncoder().encode(body)
        self.body = body
    }

}
