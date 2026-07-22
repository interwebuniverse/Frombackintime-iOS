//
//  Date+Arrival.swift
//  FromBackInTime
//
//  Human wording for a future delivery moment. RelativeDateTimeFormatter
//  always rounds down, so one year out prints as "in 11 months" and reads
//  like a bug next to an "In a year" chip. This rounds to the nearest big
//  unit instead.
//

import Foundation

extension Date {
    var friendlyArrival: String {
        let seconds = timeIntervalSinceNow
        let days = seconds / 86_400
        if days >= 350 {
            let years = max(Int((days / 365.25).rounded()), 1)
            return years == 1 ? "in a year" : "in \(years) years"
        }
        if days >= 27 {
            let months = max(Int((days / 30.44).rounded()), 1)
            return months == 1 ? "in a month" : "in \(months) months"
        }
        if days >= 6.5 {
            let weeks = max(Int((days / 7).rounded()), 1)
            return weeks == 1 ? "in a week" : "in \(weeks) weeks"
        }
        if days >= 0.9 {
            let wholeDays = max(Int(days.rounded()), 1)
            return wholeDays == 1 ? "tomorrow" : "in \(wholeDays) days"
        }
        let hours = seconds / 3600
        if hours >= 0.95 {
            let wholeHours = max(Int(hours.rounded()), 1)
            return wholeHours == 1 ? "in an hour" : "in \(wholeHours) hours"
        }
        let minutes = max(Int((seconds / 60).rounded()), 1)
        return minutes == 1 ? "in a minute" : "in \(minutes) minutes"
    }
}
