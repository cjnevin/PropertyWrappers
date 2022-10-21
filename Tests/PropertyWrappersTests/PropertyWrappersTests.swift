import XCTest
@testable import PropertyWrappers

final class PropertyWrappersTests: XCTestCase {
    func testNilIfEmpty() {
        @NilIfEmpty("")
        var sut: String?
        XCTAssertNil(sut)
        sut = "17"
        XCTAssertEqual(sut, "17")
        sut = ""
        XCTAssertNil(sut)
        sut = nil
        XCTAssertNil(sut)
    }

    func testNilIfZero() {
        @NilIfZero(0)
        var sut: Int?
        XCTAssertNil(sut)
        sut = 17
        XCTAssertEqual(sut, 17)
        sut = 0
        XCTAssertNil(sut)
    }

    func testRestriction() {
        @Restrict(18, { $0 = max(18, min($0, 100)) })
        var sut: Int
        sut = 17
        XCTAssertEqual(sut, 18)
        sut = 101
        XCTAssertEqual(sut, 100)
    }

    func testRegEx() {
        @RegEx("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        var email: String
        email = "test@test.com"
        XCTAssertEqual(email, "test@test.com")
        email = "test.com"
        XCTAssertEqual(email, "test@test.com")
    }

    func testTruncatedString() {
        @Truncated(maxLength: 5)
        var sut: String
        sut = "1234567890"
        XCTAssertEqual(sut, "12345")
    }

    func testTruncatedArray() {
        @Truncated(maxLength: 5)
        var sut: [Int]
        sut = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
        XCTAssertEqual(sut, [1, 2, 3, 4, 5])
    }

    func testWithinRange() {
        @WithinRange(18...100)
        var sut: Int
        sut = 17
        XCTAssertEqual(sut, 18)
        sut = 101
        XCTAssertEqual(sut, 100)
    }
}
