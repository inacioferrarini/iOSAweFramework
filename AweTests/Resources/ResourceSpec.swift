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

import Quick
import Nimble
import OHHTTPStubs
@testable import Awe

class ResourceSpec: QuickSpec {
    
    override func spec() {
        
        describe("ResourceApi Request") {
            
            context("Full get method") {
                
                it("init must create Resource") {
                    let url = URL(string: "http://www.google.com")!
                    let resource = Resource<Person>(url: url)
                    expect(resource.url).toNot(beNil())
                    expect(resource.body).to(beNil())
                }
                
                it("init must create Resource with body") {
                    let url = URL(string: "http://www.google.com")!
                    let person = Person(name: "Fulano", age: 10, boolValue: true)
                    let resource = Resource<Person>(url: url, body: person)
                    let data = try? JSONEncoder().encode(person)
                    
                    expect(resource.url).toNot(beNil())
                    expect(resource.body).toNot(beNil())
                    expect(resource.body).to(equal(data))
                    
                }
                
            }
            
        }
        
    }
    
}
