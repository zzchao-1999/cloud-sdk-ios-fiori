// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import SwiftUI

public protocol TextViewStyle: DynamicProperty {
    associatedtype Body: View

    func makeBody(_ configuration: TextViewConfiguration) -> Body
}

struct AnyTextViewStyle: TextViewStyle {
    let content: (TextViewConfiguration) -> any View

    init(@ViewBuilder _ content: @escaping (TextViewConfiguration) -> any View) {
        self.content = content
    }

    public func makeBody(_ configuration: TextViewConfiguration) -> some View {
        self.content(configuration).typeErased
    }
}

public struct TextViewConfiguration {
    public var componentIdentifier: String = "fiori_textview_component"
    @Binding public var text: String
}

extension TextViewConfiguration {
    func isDirectChild(_ componentIdentifier: String) -> Bool {
        componentIdentifier == self.componentIdentifier
    }
}
