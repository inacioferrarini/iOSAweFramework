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
@testable import Awe

class OperatorsDecodableSpec: QuickSpec {

    override func spec() {

        describe("Operator must decode data") {

            it("Must convert Data to Decodable") {
                guard let fixtureData = FixtureHelper().objectFixture(using: "Person") else { fail("null fixture data"); return }
                var person: Person?
                person <-- fixtureData
                expect(person).toNot(beNil())
                expect(person?.name).to(equal("John Doe"))
                expect(person?.age).to(equal(12))
            }

            it("If Data cannot be transformed, it must let the object as were before") {
                guard let fixtureData = FixtureHelper().objectFixture(using: "UnparseablePerson") else { fail("null fixture data"); return }
                var person: Person?
                person <-- fixtureData
                expect(person).toNot(beNil())
                expect(person?.name).to(beNil())
                expect(person?.age).to(beNil())
            }

            it("Must convert Data Array to Decodable") {
                guard let fixtureData = FixtureHelper().objectFixture(using: "PersonArray") else { fail("null fixture data"); return }
                var personArray: [Person]?
                personArray <-- fixtureData
                expect(personArray).toNot(beNil())
                expect(personArray?.count).to(equal(2))
                expect(personArray?[0].name).to(equal("John Doe"))
                expect(personArray?[0].age).to(equal(12))
                expect(personArray?[1].name).to(equal("John Doe"))
                expect(personArray?[1].age).to(equal(32))
            }
            
            it("If Data Array cannot be transformed, it must let the object as were before") {
                guard let fixtureData = FixtureHelper().objectFixture(using: "UnparseablePersonArray") else { fail("null fixture data"); return }
                var personArray: [Person]?
                personArray <-- fixtureData
                expect(personArray).toNot(beNil())
                expect(personArray?.count).to(equal(2))
                expect(personArray?[0].name).to(beNil())
                expect(personArray?[0].age).to(beNil())
                expect(personArray?[1].name).to(beNil())
                expect(personArray?[1].age).to(beNil())
            }
            
        }

    }

}
