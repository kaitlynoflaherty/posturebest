import SwiftUI
import Charts

struct LineChart: View {
    // Sample data
    let data: [ChartData] = [
        ChartData(x: 1, y: 10),
        ChartData(x: 2, y: 20),
        ChartData(x: 3, y: 15),
        ChartData(x: 4, y: 25),
        ChartData(x: 5, y: 30)
    ]
    
    var body: some View {
        VStack {
            
            Chart(data) { dataPoint in
                LineMark(
                    x: .value("X", dataPoint.x),
                    y: .value("Y", dataPoint.y)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 300)
            .padding()
        }
    }
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart()
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}
