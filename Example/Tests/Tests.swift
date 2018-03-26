import XCTest
import cmark_gfm_swift

func firstInline(_ node: Node) -> Inline {
    guard case .paragraph(let text)? = node.elements.first else {
        fatalError("First element not a paragraph)")
    }
    return text.first!
}

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

        guard case .mention(let login) = firstInline(node) else {
            fatalError()
        }
        XCTAssertEqual(login, "user")
    }

    func testMarkdownMention_withAlpha_withNumeric() {
        let markdown = "@user123'"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .mention(let login) = firstInline(node) else {
            fatalError()
        }
        XCTAssertEqual(login, "user123")
    }

    func testMarkdownMention_withAlpha_withNumeric_withHyphen() {
        let markdown = "@user-123"
        let node = Node(markdown: markdown)!
        XCTAssertEqual(node.elements.count, 1)

        guard case .mention(let login) = firstInline(node) else {
            fatalError()
        }
        XCTAssertEqual(login, "user-123")
    }
    
}
