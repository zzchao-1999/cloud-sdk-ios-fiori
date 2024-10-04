import FioriSwiftUICore
import Foundation
import SwiftUI

struct DateTimePickerExample: View {
    @State var s1: Date = .init(timeIntervalSince1970: 0.0)
    @State var s2: Date = .init()
    @State var s3: Date = .init()
    @State var s4: Date = .init()
    @State var s5: Date = .now
    @State var isRequired = false
    @State var showsErrorMessage = false
    
    struct CustomTitleStyle: TitleStyle {
        func makeBody(_ configuration: TitleConfiguration) -> some View {
            Title(configuration)
                .font(.fiori(forTextStyle: .title3))
                .foregroundStyle(Color.preferredColor(.indigo7))
        }
    }
    
    struct CustomIndicatorStyle: MandatoryFieldIndicatorStyle {
        func makeBody(_ configuration: MandatoryFieldIndicatorConfiguration) -> some View {
            MandatoryFieldIndicator(configuration)
                .font(.fiori(forTextStyle: .title3))
                .foregroundStyle(Color.preferredColor(.indigo7))
        }
    }
    
    struct CustomValueLabelStyle: ValueLabelStyle {
        func makeBody(_ configuration: ValueLabelConfiguration) -> some View {
            ValueLabel(configuration)
                .font(.fiori(forTextStyle: .callout))
                .foregroundStyle(Color.preferredColor(.green7))
        }
    }
    
    var body: some View {
        List {
            Toggle("Mandatory Field", isOn: self.$isRequired)
            Toggle("Show Error/Hint message", isOn: self.$showsErrorMessage)
            
            DateTimePicker(title: "Default", isRequired: self.isRequired, selectedDate: self.$s1)
                .informationView(isPresented: self.$showsErrorMessage, description: AttributedString("The Date should before December."))
                .informationViewStyle(.informational)
            DateTimePicker(title: "Date only", isRequired: self.isRequired, selectedDate: self.$s2, pickerComponents: [.date])
                .informationView(isPresented: self.$showsErrorMessage, description: AttributedString("The Date should before December."))
                .informationViewStyle(.error)
            DateTimePicker(title: "Time only", isRequired: self.isRequired, selectedDate: self.$s3, pickerComponents: [.hourAndMinute])
         
            DateTimePicker(title: "Custom Style", isRequired: self.isRequired, selectedDate: self.$s4)
                .titleStyle(CustomTitleStyle())
                .mandatoryFieldIndicatorStyle(CustomIndicatorStyle())
                .valueLabelStyle(CustomValueLabelStyle())
            Text("Disabled")
            DateTimePicker(title: "In Disabled Mode", controlState: .disabled, selectedDate: self.$s5)
                .disabled(true)
            Text("Read-Only")
            DateTimePicker(title: "In Read-Only Mode", controlState: .readOnly, selectedDate: self.$s5, pickerComponents: [.date])
        }
    }
}

struct DateTimePickerExample_Previews: PreviewProvider {
    static var previews: some View {
        DateTimePickerExample()
    }
}