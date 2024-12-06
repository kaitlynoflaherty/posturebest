import Foundation
import SwiftUI

// Define a function to generate chart data dynamically
func generateChartData() -> [Date: (overallScore: Double, shoulderScore: Double, backScore: Double, spinalStraightness: Double)] {
    var generatedData: [Date: (overallScore: Double, shoulderScore: Double, backScore: Double, spinalStraightness: Double)] = [:]
    
    let now = Date()
    
    // Starting base scores for each type (higher initial values for variety)
    var baseOverallScore = 70.0   // Overall score starting at 70
    var baseShoulderScore = 70.0  // Shoulder score starting at 70
    var baseBackScore = 70.0      // Back score starting at 70
    var baseSpinalStraightness = 70.0 // Spinal straightness starting at 70
    
    // Weekly improvement factors for each score type (different growth rates)
    let weeklyImprovementOverall = 4.0 // Overall score improves by 4 points per week
    let weeklyImprovementShoulder = 3.0 // Shoulder improves by 3 points per week
    let weeklyImprovementBack = 5.0 // Back improves by 5 points per week
    let weeklyImprovementSpinal = 2.0 // Spinal straightness improves by 2 points per week
    
    // Generate data for the past 27 days (2 entries per hour)
    for i in 0..<27 {
        let dayInterval = TimeInterval(-i * 86400) // 86400 seconds in a day
        let baseDate = now.addingTimeInterval(dayInterval) // Start date for each day
        
        // Calculate the week offset from the current date (0 is the most recent week)
        let weekOffset = (26 - i) / 7  // This makes weekOffset higher for the most recent week
        
        // Apply a gradual increase each week (different growth rates for each score)
        let weekImprovementOverall = weeklyImprovementOverall * Double(weekOffset)  // Overall score growth
        let weekImprovementShoulder = weeklyImprovementShoulder * Double(weekOffset)  // Shoulder score growth
        let weekImprovementBack = weeklyImprovementBack * Double(weekOffset)  // Back score growth
        let weekImprovementSpinal = weeklyImprovementSpinal * Double(weekOffset)  // Spinal straightness growth
        
        // Update base scores with the weekly improvement for each score type
        baseOverallScore = 70.0 + weekImprovementOverall
        baseShoulderScore = 70.0 + weekImprovementShoulder
        baseBackScore = 70.0 + weekImprovementBack
        baseSpinalStraightness = 70.0 + weekImprovementSpinal
        
        // Get the weekday for the current day
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: baseDate)
        
        // Daily variance for each score type (independent for variety)
        let dailyVarianceOverall = Double.random(in: -15...15) // Daily variance for overall score
        let dailyVarianceShoulder = Double.random(in: -10...10) // Daily variance for shoulder score
        let dailyVarianceBack = Double.random(in: -20...20) // Daily variance for back score
        let dailyVarianceSpinal = Double.random(in: -10...10) // Daily variance for spinal straightness
        
        // Weekend boost (more noticeable on weekends for a more dynamic variation)
        let weekendBoost: Double = (weekday == 7 || weekday == 1) ? Double.random(in: 10...25) : 0.0
        
        // Apply random weekday fluctuations
        let weekdayAdjustment: Double = Double.random(in: -15...15) // Random fluctuation for weekday
        
        // Separate logic for today's data (the most recent day)
        if i == 0 {
            // Today's score with applied daily variance and weekend boost if applicable
            let overallScore = min(max(baseOverallScore + weekendBoost + dailyVarianceOverall + weekdayAdjustment, 60), 100)
            let shoulderScore = min(max(baseShoulderScore + weekendBoost + dailyVarianceShoulder + weekdayAdjustment, 60), 100)
            let backScore = min(max(baseBackScore + weekendBoost + dailyVarianceBack + weekdayAdjustment, 60), 100)
            let spinalStraightness = min(max(baseSpinalStraightness + weekendBoost + dailyVarianceSpinal + weekdayAdjustment, 60), 100)
            
            // Add today's data point to the dictionary
            generatedData[baseDate] = (overallScore: overallScore,
                                       shoulderScore: shoulderScore,
                                       backScore: backScore,
                                       spinalStraightness: spinalStraightness)
            
            // Generate hourly data for today (keeping small variations for hourly data)
            for j in 0..<24 { // 24 hours in a day
                for k in 0..<2 { // 2 data points per hour (every 30 minutes)
                    let hourOffset = TimeInterval(j * 3600 + k * 1800) // 3600 seconds in an hour + 1800 seconds for 30 minutes
                    let currentDate = baseDate.addingTimeInterval(hourOffset)
                    
                    // Apply smaller noise factor for hourly fluctuations
                    let noiseFactorOverall = Double.random(in: -5...5) // Small hourly noise for overall score
                    let noiseFactorShoulder = Double.random(in: -3...3) // Small hourly noise for shoulder score
                    let noiseFactorBack = Double.random(in: -7...7) // Small hourly noise for back score
                    let noiseFactorSpinal = Double.random(in: -3...3) // Small hourly noise for spinal straightness
                    
                    // Use daily base score with small fluctuation for each hour
                    let overallScore = min(max(baseOverallScore + weekendBoost + noiseFactorOverall + weekdayAdjustment, 60), 100)
                    let shoulderScore = min(max(baseShoulderScore + weekendBoost + noiseFactorShoulder + weekdayAdjustment, 60), 100)
                    let backScore = min(max(baseBackScore + weekendBoost + noiseFactorBack + weekdayAdjustment, 60), 100)
                    let spinalStraightness = min(max(baseSpinalStraightness + weekendBoost + noiseFactorSpinal + weekdayAdjustment, 60), 100)
                    
                    // Add hourly data to dictionary
                    generatedData[currentDate] = (overallScore: overallScore,
                                                  shoulderScore: shoulderScore,
                                                  backScore: backScore,
                                                  spinalStraightness: spinalStraightness)
                }
            }
        } else {
            // Generate data for past weeks with daily fluctuations
            let dailyVarianceOverall = Double.random(in: -15...15) // High daily fluctuation for overall score
            let dailyVarianceShoulder = Double.random(in: -10...10) // Smaller daily fluctuation for shoulder score
            let dailyVarianceBack = Double.random(in: -20...20) // High daily fluctuation for back score
            let dailyVarianceSpinal = Double.random(in: -10...10) // Smaller daily fluctuation for spinal straightness
            
            // Apply random daily shift for each score type
            let overallScore = min(max(baseOverallScore + dailyVarianceOverall + weekdayAdjustment, 60), 100)
            let shoulderScore = min(max(baseShoulderScore + dailyVarianceShoulder + weekdayAdjustment, 60), 100)
            let backScore = min(max(baseBackScore + dailyVarianceBack + weekdayAdjustment, 60), 100)
            let spinalStraightness = min(max(baseSpinalStraightness + dailyVarianceSpinal + weekdayAdjustment, 60), 100)
            
            // Add daily data to dictionary for this specific day
            generatedData[baseDate] = (overallScore: overallScore,
                                       shoulderScore: shoulderScore,
                                       backScore: backScore,
                                       spinalStraightness: spinalStraightness)
            
            // Generate hourly data for past days (keeping small fluctuations)
            for j in 0..<24 { // 24 hours in a day
                for k in 0..<2 { // 2 data points per hour (every 30 minutes)
                    let hourOffset = TimeInterval(j * 3600 + k * 1800) // 3600 seconds in an hour + 1800 seconds for 30 minutes
                    let currentDate = baseDate.addingTimeInterval(hourOffset)
                    
                    // Apply small noise factor for hourly fluctuations
                    let noiseFactorOverall = Double.random(in: -5...5) // Small noise for hourly data
                    let noiseFactorShoulder = Double.random(in: -3...3)
                    let noiseFactorBack = Double.random(in: -7...7)
                    let noiseFactorSpinal = Double.random(in: -3...3)
                    
                    // Use daily base score with small fluctuation for hourly data
                    let overallScore = min(max(baseOverallScore + noiseFactorOverall + weekdayAdjustment, 60), 100)
                    let shoulderScore = min(max(baseShoulderScore + noiseFactorShoulder + weekdayAdjustment, 60), 100)
                    let backScore = min(max(baseBackScore + noiseFactorBack + weekdayAdjustment, 60), 100)
                    let spinalStraightness = min(max(baseSpinalStraightness + noiseFactorSpinal + weekdayAdjustment, 60), 100)
                    
                    // Add hourly data to dictionary
                    generatedData[currentDate] = (overallScore: overallScore,
                                                  shoulderScore: shoulderScore,
                                                  backScore: backScore,
                                                  spinalStraightness: spinalStraightness)
                }
            }
        }
    }
    
    return generatedData
}
// Hardcoded hourly data from 8 AM to 8 PM
        let hourlyData: [Date: (overallScore: Double, shoulderScore: Double, backScore: Double, spinalStraightness: Double)] = [
            // 8 AM
            Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!: (overallScore: 62.4, shoulderScore: 57.1, backScore: 60.2, spinalStraightness: 69.3),
            // 9 AM
            Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!: (overallScore: 58.3, shoulderScore: 76.8, backScore: 73.2, spinalStraightness: 62.5),
            // 10 AM (Worse backScore)
            Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!: (overallScore: 61.1, shoulderScore: 59.6, backScore: 82.3, spinalStraightness: 56.1),
            // 11 AM (Worse backScore)
            Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!: (overallScore: 62.7, shoulderScore: 64.2, backScore: 79.8, spinalStraightness: 58.9),
            // 12 PM
            Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!: (overallScore: 63.8, shoulderScore: 61.7, backScore: 62.4, spinalStraightness: 64.3),
            // 1 PM
            Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!: (overallScore: 61.6, shoulderScore: 58.3, backScore: 60.3, spinalStraightness: 70.2),
            // 2 PM (Worse backScore)
            Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!: (overallScore: 75.2, shoulderScore: 59.9, backScore: 82.9, spinalStraightness: 56.7),
            // 3 PM (Worse backScore)
            Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!: (overallScore: 63.3, shoulderScore: 71.2, backScore: 80.5, spinalStraightness: 68.8),
            // 4 PM
            Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!: (overallScore: 72.9, shoulderScore: 62.6, backScore: 68.9, spinalStraightness: 71.2),
            // 5 PM
            Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!: (overallScore: 70.1, shoulderScore: 57.5, backScore: 64.7, spinalStraightness: 63.1),
            // 6 PM
            Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!: (overallScore: 64.4, shoulderScore: 56.1, backScore: 65.2, spinalStraightness: 59.7),
            // 7 PM
            Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!: (overallScore: 61.9, shoulderScore: 60.3, backScore: 62.3, spinalStraightness: 60.5),
            // 8 PM
            Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!: (overallScore: 70.7, shoulderScore: 53.6, backScore: 61.5, spinalStraightness: 62.2)
        ]


struct ConfigureAlertsTab: View {
    
    // Call the function to generate chart data
    let chartData = generateChartData()
    
    var body: some View {
        ScrollView {
            VStack {
                // Pass the generated chart data to the LineChart component (or any other view that uses the chart data)
                LineChart(scores: chartData, hourly: hourlyData) // Assuming you have a `LineChart` component
                
                Spacer(minLength: 20)
                
                // Add more content here if needed
            }
            .padding()
        }
        .navigationTitle("Home")
        .background(Color.white.ignoresSafeArea())
    }
}

struct ConfigureAlertsTab_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureAlertsTab()
    }
}
