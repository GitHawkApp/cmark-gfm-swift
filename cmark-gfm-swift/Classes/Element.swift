//
//  Element.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/29/18.
//

import Foundation

public enum TextElement: CustomStringConvertible {
    case text(text: String)
    case softBreak
    case lineBreak
    case code(text: String)
    case emphasis(children: [TextElement])
    case strong(children: [TextElement])
    case link(children: [TextElement], title: String?, url: String?)
    case strikethrough(children: [TextElement])
    case mention(login: String)
    case checkbox(checked: Bool, originalRange: NSRange)

    public var description: String {
        switch self {
        case .text(let text): return text
        case .softBreak: return "\n"
        case .lineBreak: return "\n"
        case .code(let text): return "`\(text)`"
        case .emphasis(let children): return "_\(children.map { $0.description }.joined())_"
        case .strong(let children): return "**\(children.map { $0.description }.joined())**"
        case .link(let children, let title, let url): return "[\(children.map { $0.description }.joined())](\(url ?? String()) \"\(title ?? String())\""
        case .strikethrough(let children): return "~~\(children.map { $0.description }.joined())~~"
        case .mention(let login): return "@\(login)"
        case .checkbox(let checked, _):
            let x = checked ? "x" : " "
            return "[\(x)]"
        }
    }
}

extension Inline {
    var textElement: TextElement? {
        switch self {
        case .text(let text): return .text(text: text)
        case .softBreak: return .softBreak
        case .lineBreak: return .lineBreak
        case .code(let text): return .code(text: text)
        case .emphasis(let children): return .emphasis(children: children.flatMap { $0.textElement })
        case .strong(let children): return .strong(children: children.flatMap { $0.textElement })
        case .custom(let literal): return .text(text: literal)
        case .link(let children, let title, let url):
            return .link(children: children.flatMap { $0.textElement }, title: title, url: url)
        case .strikethrough(let children): return .strikethrough(children: children.flatMap { $0.textElement })
        case .mention(let login): return .mention(login: login)
        case .checkbox(let checked, let originalRange): return .checkbox(checked: checked, originalRange: originalRange)
        case .image, .html: return nil
        }
    }
}

extension Sequence where Iterator.Element == Inline {
    var textElements: [TextElement] { return flatMap { $0.textElement } }
}

extension Block {
    var textElements: [TextElement]? {
        if case .paragraph(let text) = self {
            return text.textElements
        }
        return nil
    }
}

extension Sequence where Iterator.Element == Block {
    var textElements: [[TextElement]] { return flatMap { $0.textElements } }
}

public typealias TextLine = [TextElement]

public enum Element: CustomStringConvertible {
    case text(items: TextLine)
    case quote(items: TextLine)
    case image(title: String, url: String)
    case html(text: String)
    case table
    case hr
    case codeBlock(text: String, language: String?)
    case heading(text: TextLine, level: Int)
    case list(items: [[TextLine]], type: ListType)

    public var description: String {
        switch self {
        case .text(let items): return "text: \(items.map { $0.description }.joined())"
        case .quote(let items): return "quote: \(items.map { $0.description }.joined())"
        case .image(_, let url): return "image: \(url)"
        case .html(let text): return "html: \(text)"
        case .table: return "table"
        case .hr: return "hr"
        case .codeBlock(let text, _): return "codeBlock: \(text)"
        case .heading(let text, let level): return "heading-\(level): \(text)"
        case .list(let items, let type):
            let typeString: String
            switch type {
            case .ordered: typeString = "ordered"
            case .unordered: typeString = "unordered"
            }
            let joined = items.map { $0.description }.joined(separator: "\n")
            return "list-\(typeString): \(joined)"
        }
    }
}

struct FoldingOptions {
    var quoteLevel: Int
}

extension Block {
    func folded(_ options: FoldingOptions) -> [Element] {
        switch self {
        case .blockQuote(let items):
            var deeper = options
            deeper.quoteLevel += 1
            return items.flatMap { $0.folded(deeper) }
        case .codeBlock(let text, let language):
            return [.codeBlock(text: text, language: language)]
        case .custom:
            return []
        case .heading(let text, let level):
            return [.heading(text: text.textElements, level: level)]
        case .html(let text):
            return [.html(text: text)]
        case .list(let items, let type):
            // only allow text element lists
            let textItems = items.map { $0.textElements }
            return [.list(items: textItems, type: type)]
        case .paragraph(let text):
            let builder = InlineBuilder(options: options)
            text.forEach { $0.fold(builder: builder) }
            // clean up and append leftover text elements
            var els = builder.elements
            if let currentText = builder.currentText {
                els.append(currentText)
            }
            return els
        case .table(let items):
            return []
        case .tableRow(let items):
            return []
        case .tableCell(let items):
            return []
        case .tableHeader(let items):
            return []
        case .thematicBreak:
            return [.hr]
        }
    }
}

class InlineBuilder {
    let options: FoldingOptions
    var elements = [Element]()
    var text = [TextElement]()
    init(options: FoldingOptions) {
        self.options = options
    }
    var currentText: Element? {
        guard text.count > 0 else { return nil }
        return options.quoteLevel > 0 ? .quote(items: text) : .text(items: text)
    }
    func pushNonText(_ el: Element) {
        if let currentText = self.currentText {
            elements.append(currentText)
            text.removeAll()
        }
        elements.append(el)
    }
}

extension Inline {
    /// Collapse all text elements, break by image and html elements
    func fold(builder: InlineBuilder) {
        switch self {
        case .text, .softBreak, .lineBreak, .code, .emphasis, .strong,
             .custom, .link, .strikethrough, .mention, .checkbox:
            if let el = textElement {
                builder.text.append(el)
            }
        case .image(_, let title, let url):
            if let title = title, let url = url {
                builder.pushNonText(.image(title: title, url: url))
            }
        case .html(let text):
            builder.pushNonText(.html(text: text))
        }
    }
}

public extension Node {

    var flatElements: [Element] {
        return elements.flatMap { $0.folded(FoldingOptions(quoteLevel: 0)) }
    }

}
