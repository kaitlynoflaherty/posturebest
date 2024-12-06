import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let x: String  // Time period label (e.g., "6-7pm", "1 day ago")
    let overallScore: Double?
    let shoulderScore: Double?  // Shoulder posture score
    let backScore: Double?      // Back posture score
    let spinalStraightness: Double?  // Spinal straightness score
}

struct LineChart: View {
    // @State private var scores: [Date: (shoulderScore: Double, backScore: Double, spinalStraightness: Double)] = [:]
    @State private var selectedTab = 0
    @State private var selectedScore = 0
    let scores: [Date: (overallScore: Double, shoulderScore: Double, backScore: Double, spinalStraightness: Double)]
    let hourly: [Date: (overallScore: Double, shoulderScore: Double, backScore: Double, spinalStraightness: Double)]
    
    // Timer to periodically reload data
    //    @State private var timer: Timer? = nil
    //        // This method reads the data from UserDefaults
    //        func loadData() {
    //            if let savedReadings = UserDefaults.standard.array(forKey: "postureReadings") as? [[String: Any]] {
    //                var newScores: [Date: (shoulderScore: Double, backScore: Double, spinalStraightness: Double)] = [:]
    //                let calendar = Calendar.current
    //                for reading in savedReadings {
    //                    if let timestamp = reading["timestamp"] as? TimeInterval,
    //                       let graphData = reading["graphData"] as? [Float] {
    //                        let date = Date(timeIntervalSince1970: timestamp)
    //                        let shoulderScore = Double(graphData[0]) * 100 // Normalized Shoulder Balance
    //                        let backScore = Double(graphData[1]) * 100     // Normalized Hunch
    //                        let spinalStraightness = Double(graphData[2]) * 100 // Normalized Spinal Straightness
    //
    //                        newScores[date] = (shoulderScore, backScore, spinalStraightness)
    //                    }
    //
    //                }
    //
    //                self.scores = newScores
    //            }
    //        }
    
    
    func formatHour(_ hour: Int) -> String {
        let hour12 = (hour % 12 == 0) ? 12 : (hour % 12)
        let period = hour >= 12 ? "PM" : "AM"
        
        if hour == 12 {
            return "12PM"
        } else {
            return "\(hour12)\(period)"
        }
    }
    
    func scoreColor(score: Double) -> Color {
        // Ensure the score is clamped to the range [50, 80]
        let clampedScore = min(max(score, 50), 80)
        
        // Map the score to a normalized range [0, 1], where the lighter blue corresponds to lower scores
        // Adjusting the normalization range to make the difference between light and dark more drastic
        let scoreNormalized = (clampedScore - 50) / (80 - 50)  // Mapping the score from 50-80
        
        // Clamp the normalized score to the range [0, 1]
        let clampedNormalizedScore = min(max(scoreNormalized, 0), 1)
        
        // Now, make the lightness more drastic:
        // - Low scores (near 50) should be much lighter (close to 1.0)
        // - High scores (near 80) should be much darker (close to 0.1)
        let lightness: Double
        
        if clampedNormalizedScore < 0.5 {
            // For low scores (near 50), we use a much higher lightness value, close to 1.0 for lighter blue
            lightness = 1.0 - (1.0 - clampedNormalizedScore * 2) * 0.85 // Exaggerate the lightness at lower scores
        } else {
            // For higher scores (near 80), use a significantly darker lightness value, close to 0.1
            lightness = 0.1 + (clampedNormalizedScore - 0.5) * 2.5 // Exaggerate the darkness for higher scores
        }
        
        // Fixed hue value for blue in the HSL model
        let hue: Double = 240 / 360 // Blue hue (normalized to 0-1)
        let saturation: Double = 1.0 // Full saturation for vivid blue
        
        // Return the final color using HSL values
        return Color(hue: hue, saturation: saturation, brightness: lightness)
    }
    
    func calculateHourlyAverages() -> [ChartDataPoint] {
        var aggregatedData: [String: (overallScores: [Double], shoulderScores: [Double], backScores: [Double], spinalScores: [Double])] = [:]
        let calendar = Calendar.current
        
        for (date, score) in hourly {
            let hour = calendar.component(.hour, from: date)
            let formattedHour = formatHour(hour)
            
            let overallScore = score.overallScore
            let shoulderScore = score.shoulderScore
            let backScore = score.backScore
            let spinalScore = score.spinalStraightness
            
            if var data = aggregatedData[formattedHour] {
                data.overallScores.append(overallScore)
                data.shoulderScores.append(shoulderScore)
                data.backScores.append(backScore)
                data.spinalScores.append(spinalScore)
                aggregatedData[formattedHour] = data
            } else {
                aggregatedData[formattedHour] = (overallScores: [overallScore], shoulderScores: [shoulderScore], backScores: [backScore], spinalScores: [spinalScore])
            }
        }
        
        var hourlyData: [ChartDataPoint] = []
        
        for hour in 6..<24 {
            let formattedHour = formatHour(hour)
            let overallScore = aggregatedData[formattedHour]?.overallScores.reduce(0, +) ?? 0
            let shoulderScore = aggregatedData[formattedHour]?.shoulderScores.reduce(0, +) ?? 0
            let backScore = aggregatedData[formattedHour]?.backScores.reduce(0, +) ?? 0
            let spinalScore = aggregatedData[formattedHour]?.spinalScores.reduce(0, +) ?? 0
            
            let dataPoint = ChartDataPoint(
                x: formattedHour,
                overallScore: overallScore > 0 ? overallScore / Double(aggregatedData[formattedHour]?.overallScores.count ?? 1) : 0,
                shoulderScore: shoulderScore > 0 ? shoulderScore / Double(aggregatedData[formattedHour]?.shoulderScores.count ?? 1) : 0,
                backScore: backScore > 0 ? backScore / Double(aggregatedData[formattedHour]?.backScores.count ?? 1) : 0,
                spinalStraightness: spinalScore > 0 ? spinalScore / Double(aggregatedData[formattedHour]?.spinalScores.count ?? 1) : 0
            )
            
            hourlyData.append(dataPoint)
        }
        
        return hourlyData
    }
    
    func calculateDailyAverages() -> [ChartDataPoint] {
        var aggregatedData: [String: (overallScores: [Double], shoulderScores: [Double], backScores: [Double], spinalScores: [Double])] = [:]
        let calendar = Calendar.current
        let now = Date()
        
        // Hardcoded order of days (Fri -> Thu)
        let weekdays = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"]
        
        // Iterate over all the scores
        for (date, score) in scores {
            let startOfDay = calendar.startOfDay(for: date)
            let daysAgo = calendar.dateComponents([.day], from: startOfDay, to: calendar.startOfDay(for: now)).day!
            
            // Calculate which weekday it corresponds to
            let weekdayIndex = (7 - (daysAgo % 7)) % 7 // Ensure proper index for past days
            let dayLabel = weekdays[weekdayIndex]
            
            let overallScore = score.overallScore
            let shoulderScore = score.shoulderScore
            let backScore = score.backScore
            let spinalScore = score.spinalStraightness
            
            // Aggregate scores for each day
            if var data = aggregatedData[dayLabel] {
                data.overallScores.append(overallScore)
                data.shoulderScores.append(shoulderScore)
                data.backScores.append(backScore)
                data.spinalScores.append(spinalScore)
                aggregatedData[dayLabel] = data
            } else {
                aggregatedData[dayLabel] = (overallScores: [overallScore], shoulderScores: [shoulderScore], backScores: [backScore], spinalScores: [spinalScore])
            }
        }
        
        // Generate the past 7 days, starting with "Fri" on the left
        var result: [ChartDataPoint] = []
        
        // Hardcode the days in the exact order: Fri, Sat, Sun, Mon, Tue, Wed, Thu
        for dayLabel in weekdays {
            // Get the aggregated scores for the day or default to empty arrays if no data exists
            let data = aggregatedData[dayLabel] ?? (overallScores: [], shoulderScores: [], backScores: [], spinalScores: [])
            
            // Calculate the average scores for the day (default to 0 if no data exists)
            let avgOverallScore = data.overallScores.isEmpty ? 0 : data.overallScores.reduce(0, +) / Double(data.overallScores.count)
            let avgShoulderScore = data.shoulderScores.isEmpty ? 0 : data.shoulderScores.reduce(0, +) / Double(data.shoulderScores.count)
            let avgBackScore = data.backScores.isEmpty ? 0 : data.backScores.reduce(0, +) / Double(data.backScores.count)
            let avgSpinalScore = data.spinalScores.isEmpty ? 0 : data.spinalScores.reduce(0, +) / Double(data.spinalScores.count)
            
            // Create a ChartDataPoint for the current day
            let chartDataPoint = ChartDataPoint(
                x: dayLabel,  // Day label ("Fri", "Sat", etc.)
                overallScore: avgOverallScore,
                shoulderScore: avgShoulderScore,
                backScore: avgBackScore,
                spinalStraightness: avgSpinalScore
            )
            
            // Add the generated data point to the result array
            result.append(chartDataPoint)
        }
        
        // Return the result
        return result
    }
    
    // Calculate weekly averages and date ranges for the last 4 weeks
    func calculateWeeklyAverages() -> [ChartDataPoint] {
        var aggregatedData: [String: (overallScores: [Double], shoulderScores: [Double], backScores: [Double], spinalScores: [Double])] = [:]
        let calendar = Calendar.current
        let now = Date()
        
        // Iterate over all the scores
        for (date, score) in scores {
            let startOfDay = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.year, .weekOfYear], from: startOfDay)
            let weekOfYear = "\(components.year!)-W\(components.weekOfYear!)"  // Week identifier (Year-Wk)
            
            let overallScore = score.overallScore
            let shoulderScore = score.shoulderScore
            let backScore = score.backScore
            let spinalScore = score.spinalStraightness
            
            // Aggregate scores for each week
            if var data = aggregatedData[weekOfYear] {
                data.overallScores.append(overallScore)
                data.shoulderScores.append(shoulderScore)
                data.backScores.append(backScore)
                data.spinalScores.append(spinalScore)
                aggregatedData[weekOfYear] = data
            } else {
                aggregatedData[weekOfYear] = (overallScores: [overallScore], shoulderScores: [shoulderScore], backScores: [backScore], spinalScores: [spinalScore])
            }
        }
        
        // Get the last 4 weeks, even if they have no data
        let lastFourWeeks = getLastFourWeeks(from: now)
        var result: [ChartDataPoint] = []
        
        // Reverse the order of weeks to have the most recent on the right
        for week in lastFourWeeks.reversed() {
            let data = aggregatedData[week] ?? (overallScores: [], shoulderScores: [], backScores: [], spinalScores: [])
            
            // Calculate the average scores for the week, or use nil if no data
            let avgOverallScore = data.overallScores.isEmpty ? nil : data.overallScores.reduce(0, +) / Double(data.overallScores.count)
            let avgShoulderScore = data.shoulderScores.isEmpty ? nil : data.shoulderScores.reduce(0, +) / Double(data.shoulderScores.count)
            let avgBackScore = data.backScores.isEmpty ? nil : data.backScores.reduce(0, +) / Double(data.backScores.count)
            let avgSpinalScore = data.spinalScores.isEmpty ? nil : data.spinalScores.reduce(0, +) / Double(data.spinalScores.count)
            
            // Calculate the start and end dates for the week
            let weekRange = getWeekDateRange(from: week)
            
            let chartDataPoint = ChartDataPoint(
                x: weekRange,  // Week label in the form "MM/DD-MM/DD"
                overallScore: avgOverallScore,
                shoulderScore: avgShoulderScore,
                backScore: avgBackScore,
                spinalStraightness: avgSpinalScore
            )
            
            result.append(chartDataPoint)
        }
        
        return result
    }
    
    // Helper function to get the last 4 weeks, even if they have no data
    func getLastFourWeeks(from currentDate: Date) -> [String] {
        let calendar = Calendar.current
        var weeks: [String] = []
        
        // Get the current week and the previous three weeks
        for i in 0..<4 {
            let date = calendar.date(byAdding: .weekOfYear, value: -i, to: currentDate)!
            let components = calendar.dateComponents([.year, .weekOfYear], from: date)
            let weekOfYear = "\(components.year!)-W\(components.weekOfYear!)"
            weeks.append(weekOfYear)
        }
        
        return weeks
    }
    
    // Helper function to get the date range for a week (e.g., "11/20-11/27")
    func getWeekDateRange(from week: String) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww"
        
        if let weekStartDate = formatter.date(from: week) {
            let startOfWeek = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: weekStartDate) + 1, to: weekStartDate)!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            
            formatter.dateFormat = "MM/dd"
            let startDateString = formatter.string(from: startOfWeek)
            let endDateString = formatter.string(from: endOfWeek)
            
            return "\(startDateString)-\(endDateString)"
        }
        return ""
    }
    
    var body: some View {
        VStack {
            Picker("Select View", selection: $selectedTab) {
                Text("Day").tag(0)
                Text("Week").tag(1)
                Text("Month").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            //
            //            // Data load on appear
            //            .onAppear {
            //            loadData() // Load the data when the view appears
            //
            //                    // Set up a timer to reload data every 30 seconds (for example)
            //                    timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            //                        loadData() // Reload the data periodically
            //                    }
            //                }
            //            .onDisappear {
            //                    // Invalidate the timer when the view disappears to prevent memory leaks
            //                    timer?.invalidate()
            //                    timer = nil
            //                }
            
            HStack(spacing: 0) {
                // Overall Button
                Button(action: { selectedScore = 0 }) {
                    VStack {
                        Circle()
                            .fill(selectedScore == 0 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("O")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                        Text("Overall Score")
                            .font(.system(size: 10))
                            .foregroundColor(selectedScore == 0 ? .blue : .gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Ensure it takes up full available space
                }
                .buttonStyle(PlainButtonStyle())
                // Shoulder Button
                Button(action: { selectedScore = 1 }) {
                    VStack {
                        Circle()
                            .fill(selectedScore == 1 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("S")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                        Text("Shoulder Balance")
                            .font(.system(size: 10)) // Adjust font size here
                            .foregroundColor(selectedScore == 1 ? .blue : .gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Ensure it takes up full available space
                }
                .buttonStyle(PlainButtonStyle())
                
                // Back Button
                Button(action: { selectedScore = 2 }) {
                    VStack {
                        Circle()
                            .fill(selectedScore == 2 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("B")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                        Text("Back Hunch")
                            .font(.system(size: 10))
                            .foregroundColor(selectedScore == 2 ? .blue : .gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Ensure it takes up full available space
                }
                .buttonStyle(PlainButtonStyle())
                
                // Spinal Button
                Button(action: { selectedScore = 3 }) {
                    VStack {
                        Circle()
                            .fill(selectedScore == 3 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("P")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                        Text("Spinal Alignment")
                            .font(.system(size: 10))
                            .foregroundColor(selectedScore == 3 ? .blue : .gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Ensure it takes up full available space
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top)
            
            // Bar chart for the selected score
            if selectedTab == 0 {
                VStack {
                    Text("Today")
                    .font(.headline)
                    if selectedScore == 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(calculateHourlyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Hour", dataPoint.x),
                                    y: .value("Overall Score", dataPoint.overallScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.overallScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                            .frame(width: 800) // Set width for scrolling
                        }
                    } else if selectedScore == 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(calculateHourlyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Hour", dataPoint.x),
                                    y: .value("Shoulder Score", dataPoint.shoulderScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.shoulderScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                            .frame(width: 800) // Set width for scrolling
                        }
                    }
                    else if selectedScore == 2 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(calculateHourlyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Hour", dataPoint.x),
                                    y: .value("Back Score", dataPoint.backScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.backScore ?? 0))
                            }
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .frame(height: 250)
                            .chartYScale(domain: 0...100)
                            .padding()
                            .frame(width: 800) // Set width for scrolling
                        }
                    }
                    else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(calculateHourlyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Hour", dataPoint.x),
                                    y: .value("Spinal Straightness", dataPoint.spinalStraightness ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.spinalStraightness ?? 0))
                            }
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .frame(height: 250)
                            .chartYScale(domain: 0...100)
                            .padding()
                            .frame(width: 800) // Set width for scrolling
                        }
                    }
                }
            }
                else if selectedTab == 1 {
                    VStack {
                        Text("This Week")
                            .font(.headline)
                        if selectedScore == 0 {
                            Chart(calculateDailyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.x),
                                    y: .value("Shoulder Score", dataPoint.overallScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.overallScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        }
                        else if selectedScore == 1 {
                            Chart(calculateDailyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.x),
                                    y: .value("Shoulder Score", dataPoint.shoulderScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.shoulderScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        } else if selectedScore == 2 {
                            Chart(calculateDailyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.x),
                                    y: .value("Back Score", dataPoint.backScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.backScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        } else {
                            Chart(calculateDailyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Day", dataPoint.x),
                                    y: .value("Spinal Straightness", dataPoint.spinalStraightness ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.spinalStraightness ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        }
                    }
                }
                else {
                    VStack {
                        Text("This Month")
                            .font(.headline)
                        if selectedScore == 0 {
                            Chart(calculateWeeklyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Week", dataPoint.x),
                                    y: .value("Overall Score", dataPoint.overallScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.overallScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        }
                        else if selectedScore == 1 {
                            Chart(calculateWeeklyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Week", dataPoint.x),
                                    y: .value("Shoulder Score", dataPoint.shoulderScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.shoulderScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        } else if selectedScore == 2 {
                            Chart(calculateWeeklyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Week", dataPoint.x),
                                    y: .value("Back Score", dataPoint.backScore ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.backScore ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                            
                        } else {
                            Chart(calculateWeeklyAverages()) { dataPoint in
                                BarMark(
                                    x: .value("Week", dataPoint.x),
                                    y: .value("Spinal Straightness", dataPoint.spinalStraightness ?? 0)
                                )
                                .foregroundStyle(scoreColor(score: dataPoint.spinalStraightness ?? 0))
                            }
                            .frame(height: 250)
                            .chartYAxis {
                                        AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .padding()
                        }
                    }
                }
            }
                .padding()
        }
    }

