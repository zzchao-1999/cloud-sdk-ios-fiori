// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
//TODO: Copy commented code to new file: `FioriSwiftUICore/Views/FilterFeedbackBarButton+View.swift`
//TODO: Implement default Fiori style definitions as `ViewModifier`
//TODO: Implement FilterFeedbackBarButton `View` body
//TODO: Implement LibraryContentProvider

/// - Important: to make `@Environment` properties (e.g. `horizontalSizeClass`), internally accessible
/// to extensions, add as sourcery annotation in `FioriSwiftUICore/Models/ModelDefinitions.swift`
/// to declare a wrapped property
/// e.g.:  `// sourcery: add_env_props = ["horizontalSizeClass"]`

/*
import SwiftUI

// FIXME: - Implement Fiori style definitions

extension Fiori {
    enum FilterFeedbackBarButton {
        typealias LeftIcon = EmptyModifier
        typealias LeftIconCumulative = EmptyModifier
		typealias Title = EmptyModifier
        typealias TitleCumulative = EmptyModifier

        // TODO: - substitute type-specific ViewModifier for EmptyModifier
        /*
            // replace `typealias Subtitle = EmptyModifier` with:

            struct Subtitle: ViewModifier {
                func body(content: Content) -> some View {
                    content
                        .font(.body)
                        .foregroundColor(.preferredColor(.primary3))
                }
            }
        */
        static let leftIcon = LeftIcon()
		static let title = Title()
        static let leftIconCumulative = LeftIconCumulative()
		static let titleCumulative = TitleCumulative()
    }
}

// FIXME: - Implement FilterFeedbackBarButton View body

extension FilterFeedbackBarButton: View {
    public var body: some View {
        <# View body #>
    }
}

// FIXME: - Implement FilterFeedbackBarButton specific LibraryContentProvider

@available(iOS 14.0, macOS 11.0, *)
struct FilterFeedbackBarButtonLibraryContent: LibraryContentProvider {
    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(FilterFeedbackBarButton(model: LibraryPreviewData.Person.laurelosborn),
                    category: .control)
    }
}
*/
