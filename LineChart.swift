import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let x: String  // Time period label (e.g., "6-7pm", "1 day ago")
    let shoulderScore: Double?  // Shoulder posture score
    let backScore: Double?      // Back posture score
    let spinalStraightness: Double?  // Spinal straightness score
}

struct LineChart: View {
    let scores: [Date: (shoulderScore: Double, backScore: Double, spinalStraightness: Double)]

    func formatHour(_ hour: Int) -> String {
        let hour12 = (hour % 12 == 0) ? 12 : (hour % 12)
        let period = hour >= 12 ? "PM" : "AM"
        
        if hour == 12 {
            return "12-1pm"
        } else {
            return "\(hour12)-\(hour12 + 1) \(period)"
        }
    }

    func scoreColor(score: Double) -> Color {
        switch score {
        case 0..<33:
            return .red.opacity(0.6)
        case 33..<66:
            return .yellow.opacity(0.6)
        default:
            return .green.opacity(0.6)
        }
    }

    func calculateHourlyAverages() -> [ChartDataPoint] {
        var aggregatedData: [String: (shoulderScores: [Double], backScores: [Double], spinalScores: [Double])] = [:]
        let calendar = Calendar.current
        
        for (date, score) in scores {
            let hour = calendar.component(.hour, from: date)
            let formattedHour = formatHour(hour)
            
            let shoulderScore = score.shoulderScore
            let backScore = score.backScore
            let spinalScore = score.spinalStraightness
            
            if var data = aggregatedData[formattedHour] {
                data.shoulderScores.append(shoulderScore)
                data.backScores.append(backScore)
                data.spinalScores.append(spinalScore)
                aggregatedData[formattedHour] = data
            } else {
                aggregatedData[formattedHour] = (shoulderScores: [shoulderScore], backScores: [backScore], spinalScores: [spinalScore])
            }
        }

        var hourlyData: [ChartDataPoint] = []

        for hour in 0..<24 {
            let formattedHour = formatHour(hour)
            let shoulderScore = aggregatedData[formattedHour]?.shoulderScores.reduce(0, +) ?? 0
            let backScore = aggregatedData[formattedHour]?.backScores.reduce(0, +) ?? 0
            let spinalScore = aggregatedData[formattedHour]?.spinalScores.reduce(0, +) ?? 0

            let dataPoint = ChartDataPoint(
                x: formattedHour,
                shoulderScore: shoulderScore > 0 ? shoulderScore / Double(aggregatedData[formattedHour]?.shoulderScores.count ?? 1) : 0,
                backScore: backScore > 0 ? backScore / Double(aggregatedData[formattedHour]?.backScores.count ?? 1) : 0,
                spinalStraightness: spinalScore > 0 ? spinalScore / Double(aggregatedData[formattedHour]?.spinalScores.count ?? 1) : 0
            )

            hourlyData.append(dataPoint)
        }
        
        return hourlyData
    }

    func calculateDailyAverages() -> [ChartDataPoint] {
        var aggregatedData: [String: (shoulderScores: [Double], backScores: [Double], spinalScores: [Double])] = [:]
        let calendar = Calendar.current
        
        for (date, score) in scores {
            let startOfDay = calendar.startOfDay(for: date)
            let daysAgo = calendar.dateComponents([.day], from: startOfDay, to: calendar.startOfDay(for: Date())).day!
            let dayLabel = daysAgo == 0 ? "Today" : "\(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"
            
            let shoulderScore = score.shoulderScore
            let backScore = score.backScore
            let spinalScore = score.spinalStraightness
            
            if var data = aggregatedData[dayLabel] {
                data.shoulderScores.append(shoulderScore)
                data.backScores.append(backScore)
                data.spinalScores.append(spinalScore)
                aggregatedData[dayLabel] = data
            } else {
                aggregatedData[dayLabel] = (shoulderScores: [shoulderScore], backScores: [backScore], spinalScores: [spinalScore])
            }
        }

        return aggregatedData
            .map { (dayLabel, scores) in
                ChartDataPoint(
                    x: dayLabel,
                    shoulderScore: scores.shoulderScores.reduce(0, +) / Double(scores.shoulderScores.count),
                    backScore: scores.backScores.reduce(0, +) / Double(scores.backScores.count),
                    spinalStraightness: scores.spinalScores.reduce(0, +) / Double(scores.spinalScores.count)
                )
            }
            .sorted { (dataPoint1, dataPoint2) in
                        let order1 = Int(dataPoint1.x.split(separator: " ")[0]) ?? 0
                        let order2 = Int(dataPoint2.x.split(separator: " ")[0]) ?? 0
                        return order1 > order2
            }
    }

    @State private var selectedTab = 0
    @State private var selectedScore = 0

    var body: some View {
        VStack {
            Picker("Select View", selection: $selectedTab) {
                Text("Hourly").tag(0)
                Text("Daily").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

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

            if selectedTab == 0 {
                VStack {
                    Text("Hourly Average (Today)")
                        .font(.headline)

                    if selectedScore == 0 {
                        Chart(calculateHourlyAverages()) { dataPoint in
                            BarMark(
                                x: .value("Hour", dataPoint.x),
                                y: .value("Shoulder Score", dataPoint.shoulderScore ?? 0)
                            )
                            .foregroundStyle(scoreColor(score: dataPoint.shoulderScore ?? 0))
                        }
                        .frame(height: 250)
                        .padding()
                    } else if selectedScore == 1 {
                        Chart(calculateHourlyAverages()) { dataPoint in
                            BarMark(
                                x: .value("Hour", dataPoint.x),
                                y: .value("Back Score", dataPoint.backScore ?? 0)
                            )
                            .foregroundStyle(scoreColor(score: dataPoint.backScore ?? 0))
                        }
                        .frame(height: 250)
                        .padding()
                        
                    } else {
                        Chart(calculateHourlyAverages()) { dataPoint in
                            BarMark(
                                x: .value("Hour", dataPoint.x),
                                y: .value("Spinal Straightness", dataPoint.spinalStraightness ?? 0)
                            )
                            .foregroundStyle(scoreColor(score: dataPoint.spinalStraightness ?? 0))
                        }
                        .frame(height: 250)
                        .padding()
                    }
                }
            } else {
                VStack {
                    Text("Daily Average (Past Days)")
                        .font(.headline)

                    if selectedScore == 0 {
                        Chart(calculateDailyAverages()) { dataPoint in
                            BarMark(
                                x: .value("Day", dataPoint.x),
                                y: .value("Shoulder Score", dataPoint.shoulderScore ?? 0)
                            )
                            .foregroundStyle(scoreColor(score: dataPoint.shoulderScore ?? 0))
                        }
                        .frame(height: 250)
                        .padding()
                    } else if selectedScore == 1 {
                        Chart(calculateDailyAverages()) { dataPoint in
                            BarMark(
                                x: .value("Day", dataPoint.x),
                                y: .value("Back Score", dataPoint.backScore ?? 0)
                            )
                            .foregroundStyle(scoreColor(score: dataPoint.backScore ?? 0))
                        }
                        .frame(height: 250)
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
                        .padding()
                    }
                }
            }
        }
        .padding()
    }
}
