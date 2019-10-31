import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ztory_ios_downloaderTests.allTests),
    ]
}
#endif
