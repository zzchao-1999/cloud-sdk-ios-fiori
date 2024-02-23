// Generated using Sourcery 2.1.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import SwiftUI

public protocol LabelItemStyle: DynamicProperty {
    associatedtype Body: View

    func makeBody(_ configuration: LabelItemConfiguration) -> Body
}
    
struct AnyLabelItemStyle: LabelItemStyle {
    let content: (LabelItemConfiguration) -> any View

    init(@ViewBuilder _ content: @escaping (LabelItemConfiguration) -> any View) {
        self.content = content
    }

    public func makeBody(_ configuration: LabelItemConfiguration) -> some View {
        self.content(configuration).typeErased
    }
}
    
public struct LabelItemConfiguration {
    public let icon: Icon
    public let title: Title
    public let alignment: HorizontalAlignment?

    public typealias Icon = ConfigurationViewWrapper
    public typealias Title = ConfigurationViewWrapper
}
    
public struct LabelItemFioriStyle: LabelItemStyle {
    public func makeBody(_ configuration: LabelItemConfiguration) -> some View {
        LabelItem(configuration)
            .iconStyle(IconFioriStyle())
            .titleStyle(TitleFioriStyle())
    }
}
