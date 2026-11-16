//
//  MaskedTextFieldPasteTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

@MainActor
class MaskedTextFieldPasteTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var configuration: VGSConfiguration!
    var textfield: VGSTextField!

    override func setUp() {
        super.setUp()
        collector = VGSCollect(id: "vaultid", environment: .sandbox)
        configuration = VGSConfiguration(collector: collector, fieldName: "test")
        textfield = VGSTextField()
        textfield.configuration = configuration
    }

    override func tearDown() {
        textfield = nil
        configuration = nil
        collector = nil
        super.tearDown()
    }

    func testUnmaskedPasteWithPrefixPreservesTextAndRange() throws {
        let field = textfield.textField
        field.prefix = "+1"
        field.secureText = "Hello world"
        let start = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: 6))
        let target = try XCTUnwrap(field.textRange(from: start, to: field.endOfDocument))

        let inserted = field.textPasteConfigurationSupporting(field,
                                                            performPasteOf: NSAttributedString(string: "😀"),
                                                            to: target)

        XCTAssertEqual(field.secureText, "Hello 😀")
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: inserted.start), 6)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: inserted.end), 8)
    }
    func testPasteRejectsStaleRange() throws {
        let field = textfield.textField
        for maxInputLength in [nil, 20] as [Int?] {
            configuration.maxInputLength = maxInputLength
            for currentText in [nil, "", "a", "abc"] as [String?] {
                field.secureText = "abcdef"
                let start = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: 2))
                let end = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: 5))
                let target = try XCTUnwrap(field.textRange(from: start, to: end))
                field.secureText = currentText
                let previousText = field.secureText

                let result = field.textPasteConfigurationSupporting(field,
                                                                  performPasteOf: NSAttributedString(string: "X"),
                                                                  to: target)

                XCTAssertEqual(field.secureText, previousText)
                XCTAssertTrue(result === target)
            }
        }
    }
}
