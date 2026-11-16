//
//  MaskedTextFieldTest.swift
//  FrameworkTests
//
//  Created by Dima on 27.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK
@MainActor
class MaskedTextFieldTest: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var configuration: VGSConfiguration!
    var textfield: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "vaultid")
        configuration = VGSConfiguration.init(collector: collector, fieldName: "test1")
        textfield = VGSTextField()
        textfield.configuration = configuration
    }
    
    override func tearDown() {
        collector  = nil
        configuration = nil
        textfield = nil
    }
    
    func testPasteCursorAfterInsertedFormatting() throws {
        try assertFormattedSelection("12345678", pattern: "#### ####", selection: 8..<8,
                                     expectedText: "1234 5678", expectedSelection: 9..<9)
    }
    func testCardFieldBulkInsertionCursor() throws {
        configuration.type = .cardNumber
        textfield.configuration = configuration
        textfield.textField.insertText("4111111111111111")
        XCTAssertEqual(textfield.textField.secureText, "4111 1111 1111 1111")
        let selection = try XCTUnwrap(textfield.textField.selectedTextRange)
        XCTAssertEqual(textfield.textField.offset(from: textfield.textField.beginningOfDocument,
                                                  to: selection.start), 19)
    }
    func testPasteCursorInMiddle() throws {
        try assertFormattedSelection("1234567890", pattern: "#### #### ####", selection: 6..<6,
                                     expectedText: "1234 5678 90", expectedSelection: 7..<7)
    }
    func testPasteCursorAfterFilteringAndTruncation() throws {
        try assertFormattedSelection("12ab34-567890", pattern: "#### ####", selection: 13..<13,
                                     expectedText: "1234 5678", expectedSelection: 9..<9)
    }
    func testSelectionSurvivesFormatting() throws {
        try assertFormattedSelection("12345678", pattern: "#### ####", selection: 2..<6,
                                     expectedText: "1234 5678", expectedSelection: 2..<7)
    }
    func testFormattedPastePreservesCursor() throws {
        try assertFormattedSelection("1234 5678", pattern: "#### ####", selection: 7..<7,
                                     expectedText: "1234 5678", expectedSelection: 7..<7)
    }
    func testUnicodePasteCursorUsesUTF16Offsets() throws {
        try assertFormattedSelection("é😀1234", pattern: "##/##", selection: 7..<7,
                                     expectedText: "12/34", expectedSelection: 5..<5)
    }
    func testUnmaskedPastePreservesCursor() throws {
        try assertFormattedSelection("Hello 😀 world", pattern: "", selection: 8..<8,
                                     expectedText: "Hello 😀 world", expectedSelection: 8..<8)
    }
    func testCursorWithDifferentMasksAndInputLengths() throws {
        let cases: [FormattingCase] = [
            .init(input: "4111111111111111", pattern: "#### #### #### ####", output: "4111 1111 1111 1111"),
            .init(input: "411111", pattern: "#### #### #### ####", output: "4111 11"),
            .init(input: "378282246310005", pattern: "#### ###### #####", output: "3782 822463 10005"),
            .init(input: "3782822", pattern: "#### ###### #####", output: "3782 822"),
            .init(input: "1230", pattern: "##/##", output: "12/30"),
            .init(input: "123", pattern: "##/##", output: "12/3"),
            .init(input: "122030", pattern: "##/####", output: "12/2030"),
            .init(input: "123456789", pattern: "###-##-####", output: "123-45-6789"),
            .init(input: "12345", pattern: "###-##-####", output: "123-45"),
            .init(input: "1234567890", pattern: "(###) ###-####", output: "(123) 456-7890"),
            .init(input: "1234", pattern: "(###) ###-####", output: "(123) 4"),
            .init(input: "ABcd12", pattern: "AA-aa-##", output: "AB-cd-12"),
            .init(input: "ABc", pattern: "AA-aa-##", output: "AB-c"),
            .init(input: "123", pattern: "####", output: "123"),
            .init(input: "12345", pattern: "####", output: "1234"),
            .init(input: "abc", pattern: "#### ####", output: ""),
            .init(input: "", pattern: "#### ####", output: ""),
            .init(input: "Jane Doe", pattern: "", output: "Jane Doe"),
            .init(input: "A😀Bé", pattern: "", output: "A😀Bé"),
            .init(input: "", pattern: "", output: "")
        ]
        for testCase in cases {
            try assertFormattedSelection(testCase.input, pattern: testCase.pattern,
                                         selection: testCase.input.utf16.count..<testCase.input.utf16.count,
                                         expectedText: testCase.output,
                                         expectedSelection: testCase.output.utf16.count..<testCase.output.utf16.count)
        }
    }
    func testNativeInsertionAndReplacementCursor() throws {
        let cases: [InsertionCase] = [
            .init(pattern: "#### #### #### ####", initial: "", selection: 0..<0, insertion: "4111111111111111", output: "4111 1111 1111 1111", cursor: 19),
            .init(pattern: "#### ####", initial: "12", selection: 2..<2, insertion: "3456", output: "1234 56", cursor: 7),
            .init(pattern: "#### ####", initial: "1256", selection: 2..<2, insertion: "34", output: "1234 56", cursor: 4),
            .init(pattern: "#### ####", initial: "1234 5678", selection: 2..<7, insertion: "90", output: "1290 78", cursor: 4),
            .init(pattern: "#### ####", initial: "1234 5678", selection: 0..<9, insertion: "987654", output: "9876 54", cursor: 7),
            .init(pattern: "##/##", initial: "12/30", selection: 3..<5, insertion: "29", output: "12/29", cursor: 5),
            .init(pattern: "###-##-####", initial: "123", selection: 3..<3, insertion: "456789", output: "123-45-6789", cursor: 11),
            .init(pattern: "AA-aa-##", initial: "AB", selection: 2..<2, insertion: "cd12", output: "AB-cd-12", cursor: 8),
            .init(pattern: "#### ####", initial: "12", selection: 2..<2, insertion: "a3-b4 56", output: "1234 56", cursor: 7),
            .init(pattern: "####", initial: "12", selection: 2..<2, insertion: "345678", output: "1234", cursor: 4),
            .init(pattern: "", initial: "Hello world", selection: 6..<11, insertion: "😀", output: "Hello 😀", cursor: 8),
            .init(pattern: "", initial: "ab", selection: 1..<1, insertion: "XYZ", output: "aXYZb", cursor: 4),
            .init(pattern: "", initial: "", selection: 0..<0, insertion: "Jane Doe", output: "Jane Doe", cursor: 8)
        ]
        for testCase in cases {
          for usePasteDelegate in [false, true] {
            let field = textfield.textField
            field.formatPattern = testCase.pattern
            field.secureText = testCase.initial
            let start = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: testCase.selection.lowerBound))
            let end = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: testCase.selection.upperBound))
            field.selectedTextRange = field.textRange(from: start, to: end)
            if usePasteDelegate {
                let target = try XCTUnwrap(field.selectedTextRange)
                _ = field.textPasteConfigurationSupporting(field, performPasteOf: NSAttributedString(string: testCase.insertion), to: target)
            } else {
                field.insertText(testCase.insertion)
            }
            XCTAssertEqual(field.secureText, testCase.output)
            let result = try XCTUnwrap(field.selectedTextRange)
            XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: result.start), testCase.cursor)
            XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: result.end), testCase.cursor)
          }
        }
    }
    private struct FormattingCase {
        let input: String
        let pattern: String
        let output: String
    }
    private struct InsertionCase {
        let pattern: String
        let initial: String
        let selection: Range<Int>
        let insertion: String
        let output: String
        let cursor: Int
    }
    private func assertFormattedSelection(_ input: String, pattern: String, selection: Range<Int>,
                                          expectedText: String, expectedSelection: Range<Int>,
                                          file: StaticString = #filePath, line: UInt = #line) throws {
        let field = textfield.textField
        field.formatPattern = ""
        field.secureText = input
        let start = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: selection.lowerBound))
        let end = try XCTUnwrap(field.position(from: field.beginningOfDocument, offset: selection.upperBound))
        field.selectedTextRange = field.textRange(from: start, to: end)
        field.formatPattern = pattern
        field.updateTextFormat()
        XCTAssertEqual(field.secureText, expectedText, file: file, line: line)
        let result = try XCTUnwrap(field.selectedTextRange)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: result.start),
                       expectedSelection.lowerBound, file: file, line: line)
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: result.end),
                       expectedSelection.upperBound, file: file, line: line)
    }
    func testDigitsMaskingText() {
        configuration.formatPattern = "#### ####-####.####"
        textfield.configuration = configuration
        textfield.textField.secureText = "011122223333444455556"
        XCTAssertTrue(textfield.textField.secureText == "0111 2222-3333.4444")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        configuration.formatPattern = "#### ####_####?##+##"
        textfield.configuration = configuration
      
        textfield.textField.secureText = ""
        XCTAssertTrue(textfield.textField.secureText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
       
        textfield.textField.secureText! += " adf"
        XCTAssertTrue(textfield.textField.secureText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
      
        textfield.textField.secureText! += " 0 1 "
        XCTAssertTrue(textfield.textField.secureText == "01")
        XCTAssertTrue(textfield.state.inputLength == 2)
      
        textfield.textField.secureText! += "112222 333344445555sd "
        XCTAssertTrue(textfield.textField.secureText == "0111 2222_3333?44+44")
        XCTAssertTrue(textfield.state.inputLength == 16)
    }
    
    func testLettersMaskingText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TEST test-tEsT.tEsTu"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.secureText == "TEST test-tEsT.tEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
    }
    
    func testLettersAndDigitMaskingText() {
        let inputText = " Aa11_22:22/33+ 2s"
      
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = inputText
        XCTAssertTrue(textfield.textField.secureText == inputText)
        XCTAssertTrue(textfield.state.inputLength == inputText.count)
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.secureText == "Aa11")
        XCTAssertTrue(textfield.state.inputLength == 4)

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.secureText == "tE./_:+25")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testGetRawDigitsText() {
        configuration.formatPattern = "#### #### #### ####"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111111111111111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111111111111111")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = " ####-####?####_####.#### "
        textfield.configuration = configuration
        textfield.textField.secureText = "411122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "41112222333344445555")
        XCTAssertTrue(textfield.state.inputLength == 20)
      
        textfield.textField.secureText = "41112"
        XCTAssertTrue(textfield.textField.getSecureRawText == "41112")
        XCTAssertTrue(textfield.state.inputLength == 5)
      
        textfield.textField.secureText = ""
        XCTAssertTrue(textfield.textField.getSecureRawText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
      
        configuration.formatPattern = " _##/## "
        textfield.configuration = configuration
        textfield.textField.secureText = "012345678"
        XCTAssertTrue(textfield.textField.getSecureRawText == "0123")
        XCTAssertTrue(textfield.state.inputLength == 4)
        
        configuration.formatPattern = "####-"
        textfield.configuration = configuration
        textfield.textField.secureText = "4111"
        XCTAssertTrue(textfield.textField.getSecureRawText == "4111")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testGetRawLettersText() {
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = "TESTtesttEsTtEsTu"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        configuration.formatPattern = "AAAA aaaa-aAaA.@@@@"
        textfield.configuration = configuration
        textfield.textField.secureText = " 1234TEST test1tEsT1tEsT"
        XCTAssertTrue(textfield.textField.getSecureRawText == "TESTtesttEsTtEsT")
        XCTAssertTrue(textfield.state.inputLength == 16)
      
        textfield.textField.secureText = "1234"
        XCTAssertTrue(textfield.textField.getSecureRawText == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
    }
    
    func testGetRawLettersAndDigitsText() {
        let inputText = " Aa11_22:22/33+ 2s"
      
        configuration.formatPattern = ""
        textfield.configuration = configuration
        textfield.textField.secureText = inputText
        XCTAssertTrue(textfield.textField.getSecureRawText == inputText)
        XCTAssertTrue(textfield.state.inputLength == inputText.count)
        
        configuration.formatPattern = "****"
        textfield.configuration = configuration
        textfield.textField.secureText = "Aa1122223333444455556"
        XCTAssertTrue(textfield.textField.getSecureRawText == "Aa11")
        XCTAssertTrue(textfield.state.inputLength == 4)
      
        textfield.textField.secureText = "a1"
        XCTAssertTrue(textfield.textField.getSecureRawText == "a1")
        XCTAssertTrue(textfield.state.inputLength == 2)

        configuration.formatPattern = "**./_:+**"
        textfield.configuration = configuration
        textfield.textField.secureText = " tE2 5test"
        XCTAssertTrue(textfield.textField.getSecureRawText == "tE25")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testAddDivider() {
        configuration.formatPattern = "#### ####-####.####"
        configuration.divider = "-"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "5252-5252-5252-5252")
        XCTAssertTrue(textfield.getOutputText() == "5252-5252-5252-5252")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.formatPattern = "-####-"
        configuration.divider = "+"
        textfield.configuration = configuration
        textfield.textField.secureText = "5252525252525252"
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "+5252+")
        XCTAssertTrue(textfield.getOutputText() == "+5252+")
        XCTAssertTrue(textfield.state.inputLength == 4)
      
        textfield.setText("")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "")
        XCTAssertTrue(textfield.state.inputLength == 0)
        
        configuration.formatPattern = " AAA/aaa/####"
        configuration.divider = "__"
        textfield.configuration = configuration
        textfield.setText("XYZxyz123456789wertert")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "__XYZ__xyz__1234")
        XCTAssertTrue(textfield.getOutputText() == "__XYZ__xyz__1234")
        XCTAssertTrue(textfield.state.inputLength == 10)
      
        textfield.setText("XYZxyz")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "__XYZ__xyz")
        XCTAssertTrue(textfield.state.inputLength == 6)
        
        configuration.formatPattern = " #-#--#---#"
        configuration.divider = "-"
        textfield.configuration = configuration
        textfield.setText("12345678")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "-1-2--3---4")
        XCTAssertTrue(textfield.getOutputText() == "-1-2--3---4")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
    
    func testDefaultDivider() {
        configuration.type = .cardNumber
        configuration.divider = nil
        configuration.formatPattern = "#### ####.####-####"
        textfield.configuration = configuration
        textfield.setText("5252525252525252")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "5252525252525252")
        XCTAssertTrue(textfield.getOutputText() == "5252525252525252")
        XCTAssertTrue(textfield.state.inputLength == 16)
        
        configuration.type = .expDate
        configuration.divider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.setText("1234")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "12/34")
        XCTAssertTrue(textfield.getOutputText() == "12/34")
        XCTAssertTrue(textfield.state.inputLength == 4)
        
        let nameInput = "Joe's Business"
        configuration.type = .cardHolderName
        configuration.divider = nil
        configuration.formatPattern = nil
        textfield.configuration = configuration
        textfield.setText(nameInput)
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == nameInput)
        XCTAssertTrue(textfield.getOutputText() == nameInput)
        XCTAssertTrue(textfield.state.inputLength == nameInput.count)
        
        configuration.type = .cvc
        configuration.formatPattern =  nil
        configuration.divider = nil
        textfield.configuration = configuration
        textfield.setText("1234")
        XCTAssertTrue(textfield.textField.getSecureTextWithDivider == "1234")
        XCTAssertTrue(textfield.getOutputText() == "1234")
        XCTAssertTrue(textfield.state.inputLength == 4)
    }
}
