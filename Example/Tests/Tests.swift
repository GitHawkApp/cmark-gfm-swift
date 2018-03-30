import XCTest
import cmark_gfm_swift

class Tests: XCTestCase {
    
    func testMarkdownToHTML() {
        let markdown = "*Hello World*"
        let html = markdownToHtml(string: markdown)
        XCTAssertEqual(html, "<p><em>Hello World</em></p>\n")
    }

    func testMarkdownToNode() {
        let markdown = "*Hello World*"
        let rootNode = Node(markdown: markdown)
        XCTAssertNotNil(rootNode)
    }

    func testMarkdownToArrayOfBlocks() {
        let markdown = """
            # Heading
            ## Subheading
            Lorem ipsum _dolor sit_ amet.
            * List item 1
            * List item 2
            > Quote
            > > Quote 2
            """
        let rootNode = Node(markdown: markdown)!
        let blocks = rootNode.elements
        XCTAssertEqual(blocks.count, 5)
    }

    func testMarkdownTable() {
        let markdown = """
            | foo | bar |
            | --- | --- |
            | baz | bim |
            """
        let rootNode = Node(markdown: markdown)!
        let blocks = rootNode.elements
        XCTAssertEqual(blocks.count, 1)
    }

    func testMarkdownStrikethrough() {
        let markdown = """
            ~~foo~~
            """
        let rootNode = Node(markdown: markdown)!
        let blocks = rootNode.elements
        XCTAssertEqual(blocks.count, 1)
    }

    func testMarkdownAutolink() {
        let markdown = """
            https://github.com
            """
        let rootNode = Node(markdown: markdown)!
        let blocks = rootNode.elements
        XCTAssertEqual(blocks.count, 1)
    }

    func testMarkdownCodeBlock() {
        let markdown = """
            ```swift
            let a = "foo"
            ```
            """
        let rootNode = Node(markdown: markdown)!
        let blocks = rootNode.elements
        XCTAssertEqual(blocks.count, 1)
    }

    func testMarkdownMention_withAlpha() {
        let markdown = "@user"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .paragraph(let paragraph)? = node.elements.first else { fatalError() }
        guard case .mention(let login)? = paragraph.first else { fatalError() }
        XCTAssertEqual(login, "user")
    }

    func testMarkdownMention_withAlpha_withNumeric() {
        let markdown = "@user123'"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .paragraph(let paragraph)? = node.elements.first else { fatalError() }
        guard case .mention(let login)? = paragraph.first else { fatalError() }
        XCTAssertEqual(login, "user123")
    }

    func testMarkdownMention_withAlpha_withNumeric_withHyphen() {
        let markdown = "@user-123"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .paragraph(let paragraph)? = node.elements.first else { fatalError() }
        guard case .mention(let login)? = paragraph.first else { fatalError() }
        XCTAssertEqual(login, "user-123")
    }

    func testMarkdownMention_withWordsSurrounding() {
        let markdown = "foo @user bar"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .paragraph(let paragraph)? = node.elements.first else { fatalError() }
        XCTAssertEqual(paragraph.count, 3)

        guard case .text(let foo) = paragraph[0] else { fatalError() }
        guard case .mention(let login) = paragraph[1] else { fatalError() }
        guard case .text(let bar) = paragraph[2] else { fatalError() }
        XCTAssertEqual(foo, "foo ")
        XCTAssertEqual(login, "user")
        XCTAssertEqual(bar, " bar")
    }

    func testMarkdownCheckbox_withUnchecked() {
        let markdown = "- [ ] test"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .list(let items, _)? = node.elements.first else { fatalError() }
        guard case .paragraph(let paragraph)? = items.first?.first else { fatalError() }
        // first element in list is an empty text node. we can filter that out later
        guard case .checkbox(let checked, let range) = paragraph[1] else { fatalError() }
        XCTAssertFalse(checked)
        XCTAssertEqual(range.location, 2)
        XCTAssertEqual(range.length, 3)
    }

    func testMarkdownCheckbox_withNestedList() {
        let markdown = """
            - [ ] foo
              - [ ] foo 2
            - [x] bar
              - [x] bar 2
            """
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)
    }

    func testMarkdownCheckbox_withChecked() {
        let markdown = "- [x] test"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .list(let items, _)? = node.elements.first else { fatalError() }
        guard case .paragraph(let paragraph)? = items.first?.first else { fatalError() }
        // first element in list is an empty text node. we can filter that out later
        guard case .checkbox(let checked, let range) = paragraph[1] else { fatalError() }
        XCTAssertTrue(checked)
        XCTAssertEqual(range.location, 2)
        XCTAssertEqual(range.length, 3)
    }

    func testMarkdownCheckbox_withCheckboxPatternInMiddleOfItem() {
        let markdown = "- foo [ ] bar"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .list(let items, _)? = node.elements.first else { fatalError() }
        guard case .paragraph(let paragraph)? = items.first?.first else { fatalError() }
        XCTAssertEqual(paragraph.count, 1)
    }

    func testMarkdownCheckbox_withCheckboxPatternInMiddleOfText() {
        let markdown = "foo [ ] bar"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .paragraph(let paragraph)? = node.elements.first else { fatalError() }
        guard case .text(let text)? = paragraph.first else { fatalError() }
        XCTAssertEqual(text, "foo [ ] bar")
    }

    func test() {
        let markdown = """
            # Heading
            ## Subheading
            Lorem @ipsum _dolor sit_ **amet**.
            * List item 1
            * List item 2
            > Quote
            > > Quote 2
            - [ ] check one
            - [x] check two
            """
        let elements = Node(markdown: markdown)!.flatElements
        XCTAssertEqual(elements.count, 7)
    }

}
