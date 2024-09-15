import SwiftUI

struct ConfigurationsView: View {
    @State private var tabState: String = "Configure Device"
    @State private var standingFreqState: String = "15"
    @State private var postureFreqState: String = "5"
    
    let tabOptions = ["Configure Device", "Configure Feedback"]
    let postureOpts = ["5", "10", "15", "20", "25", "30"]
    
    @State private var selectedTime: String = "0:00"
    
    // Stnading reminders in hours and minutes
    let hours = Array(0...5).map { String($0) }
    let minutes = ["00", "15", "30", "45"]
    
    // Combines hours and minutes into one array of options
    private var timeOptions: [String] {
        return hours.flatMap { hour in
            minutes.map { minute in
                "\(hour):\(minute)"
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Configurations")
                    .font(.largeTitle)
                    .padding()
                
                Picker("Select an option", selection: $tabState) {
                    ForEach(tabOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            VStack() {
                if tabState == "Configure Device" {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome to Vest Configuration!").font(.headline).padding(.bottom, 10)
                        // add i hover next to vest config
                        
                        Text("1. Ensure your device is on and connected to the      PostureBest app via bluetooth. \n2. Stand with your feet hip-width apart and toes pointing forward. \n3. Straighten back, neck and align shoulders to desired position. \n4. Press the configure button for 5 seconds.")
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                        
                        // Additional options and elements can go here
                    }
                    .padding()
                } else {
                    HStack {
                        Text("Standing Reminder Frequency (hours)")
                            .font(.headline)
                            .padding(.top, 20)
                        // add i hover
                        
                        Picker("Select Time", selection: $selectedTime) {
                            ForEach(timeOptions, id: \.self) { time in
                                Text(time).tag(time)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100).frame(width: 100) // Adjust height as needed
                        
                        
                    }.padding(.top, 0)
                    HStack {
                        Text("Posture Reminder Frequency (mins)")
                            .font(.headline)
                            .padding(.top, 20)
                        // add i hover
                        
                        Picker("Select Frequency", selection: $postureFreqState) {
                            ForEach(postureOpts, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(WheelPickerStyle()).frame(height: 100).frame(width: 100)
                        
                    }.padding(.top, 0)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Configurations")
        .background(Color.white.ignoresSafeArea())
        
    }
}

struct ConfigurationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationsView()
    }
}
