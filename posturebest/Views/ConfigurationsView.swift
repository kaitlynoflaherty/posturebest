import SwiftUI

struct MetricsView: View {
    let deviceName: String
    
    var body: some View {
        VStack {
            // Header Section
            VStack {
                Text("Metrics")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding()

                Text("Tracking Goals for \(deviceName)")
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.bottom)
            }
            
            // Goal Tracking Section (Previously ConfigureAlertsTab)
            ConfigureAlertsTab() // Assuming this is the view for goal tracking

            Spacer()
        }
        .navigationTitle("Metrics")
        .background(Color.white.ignoresSafeArea())
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView(deviceName: "placeholder")
    }
}
