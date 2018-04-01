import XCTest
import cmark_gfm_swift

extension TextElement {
    var string: String {
        switch self {
        case .code(let text): return text
        case .emphasis(let children): return children.string
        case .link(let children, _, _): return children.string
        case .mention(let login): return login
        case .strikethrough(let children): return children.string
        case .strong(let children): return children.string
        case .text(let text): return text
        default: return ""
        }
    }
}

extension Sequence where Iterator.Element == TextElement {
    var string: String { return reduce("") { $0 + $1.string } }
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

    func testKitchenSync() {
        let markdown = """
            # Heading
            ## Subheading
            Lorem @ipsum _dolor sit_ **amet**.
            * List item 1
            * List item 2
              * Nested list item 1
              * Nested list item 2
            > Quote
            > > Quote 2
            - [ ] check one
            - [x] check two
            """
        let elements = Node(markdown: markdown)!.flatElements
        XCTAssertEqual(elements.count, 7)

        guard case .heading(let h1, let l1) = elements[0] else { fatalError() }
        XCTAssertEqual(h1.string, "Heading")
        XCTAssertEqual(l1, 1)

        guard case .heading(let h2, let l2) = elements[1] else { fatalError() }
        XCTAssertEqual(h2.string, "Subheading")
        XCTAssertEqual(l2, 2)

        guard case .text(let t1) = elements[2] else { fatalError() }
        XCTAssertEqual(t1.string, "Lorem ipsum dolor sit amet.")

        guard case .list(let i1, _) = elements[3] else { fatalError() }
        XCTAssertEqual(i1.count, 2)
        XCTAssertEqual(i1[0].count, 1)
        XCTAssertEqual(i1[1].count, 2)

        guard case .nested(let n1, _) = i1[1][1] else { fatalError() }
        XCTAssertEqual(n1.count, 2)

        guard case .quote(let q1, let ql1) = elements[4] else { fatalError() }
        XCTAssertEqual(q1.string, "Quote")
        XCTAssertEqual(ql1, 1)

        guard case .quote(let q2, let ql2) = elements[5] else { fatalError() }
        XCTAssertEqual(q2.string, "Quote 2")
        XCTAssertEqual(ql2, 2)
    }

    func testComplicatedLists() {
        let markdown = """
            - a
              > b
              ```
              c
              ```
            - d
            """
        let elements = Node(markdown: markdown)!.flatElements
        XCTAssertEqual(elements.count, 1)
    }

    func testTables() {
        let markdown = """
            | foo | bar |
            | --- | --- |
            | baz | bim |
            """
        let elements = Node(markdown: markdown)!.flatElements
        XCTAssertEqual(elements.count, 1)

        guard case .table(let rows) = elements[0] else { fatalError() }
        XCTAssertEqual(rows.count, 2)

        guard case .header(let headerCells) = rows[0] else { fatalError() }
        XCTAssertEqual(headerCells.count, 2)
        XCTAssertEqual(headerCells[0].string, "foo")
        XCTAssertEqual(headerCells[1].string, "bar")

        guard case .row(let cells) = rows[1] else { fatalError() }
        XCTAssertEqual(cells.count, 2)
        XCTAssertEqual(cells[0].string, "baz")
        XCTAssertEqual(cells[1].string, "bim")
    }

}
