import FioriCharts
import FioriSwiftUI
import FioriSwiftUICore
import SwiftUI

struct CoreContentView: View {
    var body: some View {
        List {
            NavigationLink(
                destination: DataTableExample())
            {
                Text("Data Table")
            }
            
            NavigationLink(
                destination: BannerMessageExample())
            {
                Text("Banner Message")
            }
            
            NavigationLink(
                destination: SideBarExample(),
                label: {
                    Text("Side Bar Example")
                }
            )
            
            NavigationLink(
                destination: DimensionSelector_Chart())
            {
                Text("Dimension Selector")
            }
            
            Group {
                NavigationLink(
                    destination: StepProgressIndicatorExample())
                {
                    Text("Step Progress Indicator")
                }
                
                NavigationLink(
                    destination: SignatureCaptureViewExample())
                {
                    Text("Signature Inline View")
                }

                NavigationLink(
                    destination: SignatureCaptureViewExample2())
                {
                    Text("Customized Signature Inline View")
                }
                
                NavigationLink(
                    destination: NavigationBarExample())
                {
                    Text("Customized NavigationBar")
                }
                
                NavigationLink(
                    destination: TabViewExample())
                {
                    Text("Customized TabView")
                }
                
                NavigationLink(
                    destination: ToolbarExample())
                {
                    Text("Customized Toolbar")
                }
            }
            
            NavigationLink(
                destination: ExperimentalContentView())
            {
                Text("🚧 Experimental 🚧")
            }

            Group {
                NavigationLink(
                    destination: ListPickerItemExample())
                {
                    Text("ListPickerItem")
                }
                
                NavigationLink(
                    destination: DurationPickerExample())
                {
                    Text("DurationPicker")
                }
                
                NavigationLink(
                    destination: FioriButtonContentView(),
                    label: {
                        Text("FioriButton")
                    }
                )
                
                NavigationLink(
                    destination: IllustratedMessageExample())
                {
                    Text("IllustratedMessage")
                }
                
                Group {
                    NavigationLink(
                        destination: KPIExample())
                    {
                        Text("KPI")
                    }
                    
                    NavigationLink(
                        destination: KPIProgressExample())
                    {
                        Text("KPIProgressItem")
                    }
                    
                    NavigationLink(
                        destination: KPIHeaderExample())
                    {
                        Text("KPIHeader")
                    }
                }
                
                NavigationLink(
                    destination: OnboardingExamples())
                {
                    Text("Onboarding")
                }
                
                NavigationLink(
                    destination: ObjectItemExample(_isNewObjectItem: true),
                    label: {
                        Text("ObjectItem")
                    }
                )
                
                NavigationLink(
                    destination: ObjectItemExample(),
                    label: {
                        Text("_ObjectItem")
                    }
                )
                
                NavigationLink(
                    destination: ObjectHeaderExample(),
                    label: {
                        Text("ObjectHeader")
                    }
                )
                
                NavigationLink(destination: ContactItemExample()) {
                    Text("ContactItem")
                }
                
                NavigationLink(destination: MobileCardExample()) {
                    Text("Cards and Layouts")
                }
                
                NavigationLink(
                    destination: EmptyStateViewExample())
                {
                    Text("EmptyStateViewExample")
                }
                
                NavigationLink(destination: SortFilterExample()) {
                    Text("SortFilterExample")
                }
                
                NavigationLink(destination: SearchDemos()) {
                    Text("Search Demos")
                }

                NavigationLink(
                    destination: FormViewExamples(),
                    label: {
                        Text("FormView")
                    }
                )
            }
            
            NavigationLink(
                destination: InformationViewExample(),
                label: {
                    Text("InformationViewExample")
                }
            )
     
            NavigationLink(
                destination: LinearProgressIndicatorExample(),
                label: {
                    Text("Linear Progress Indicator")
                }
            )
            
            NavigationLink(
                destination: StepperViewExample(),
                label: {
                    Text("Stepper")
                }
            )
            
            NavigationLink(
                destination: MenuSelectionExample())
            {
                Text("Menu Selection")
            }
            
            NavigationLink(
                destination: TimelineExample(),
                label: {
                    Text("Timeline")
                }
            )
        }.navigationBarTitle("FioriSwiftUICore")
    }
}

struct CoreContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.horizontalSizeClass, .compact)
    }
}
