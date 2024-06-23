import Foundation
import Vapor

struct PeriodDate {
    let from: Date
    let to: Date
    
    var fromDateFormat: String {
        from.toDateString("yyyy-MM-dd")
    }
    
    var toDateFormat: String {
        to.toDateString("yyyy-MM-dd")
    }
    
    init(from: Date, to: Date) {
        self.from = from
        self.to = to
    }
    
    init(from: String, 
         to: String,
         format: String = "yyyy-MM-dd") {
        self.from = from.toDate(format) ?? .now
        self.to = to.toDate(format) ?? .now.goNext(days: 1)
    }
}

extension PeriodDate {
    
    static var thisYear: PeriodDate {
        let now = Date()
//        var calendar = Calendar.gregorian
//        calendar.locale = .thai
//        calendar.timeZone = .bangkok
        let calendar = Calendar.current
        
        let startOfYear = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year],
                                                                                               from: now))!)
        let endOfYear = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(year: 1,
                                                                                        day: -1),
                                                               to: startOfYear)!)
        return PeriodDate(from: startOfYear,
                          to: endOfYear)
    }
    
    static var previousYear: PeriodDate {
        let now = Date()
        let calendar = Calendar.current
        
        let startOfYear = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year],
                                                                                               from: now))!)
        let endOfYear = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(year: -1,
                                                                                        day: -1),
                                                               to: startOfYear)!)
        return PeriodDate(from: startOfYear,
                          to: endOfYear)
    }
    
    static var thisMonth: PeriodDate {
        let now = Date()
        let calendar = Calendar.current
        
        let startOfMonth = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year, .month],
                                                                                                 from: now))!)
        let endOfMonth = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(month: 1,
                                                                                          day: -1),
                                                                 to: startOfMonth)!)
        return PeriodDate(from: startOfMonth,
                          to: endOfMonth)
    }
    
    static var previousMonth: PeriodDate {
        let now = Date()
        let calendar = Calendar.current
        
        let startOfMonth = calendar.startOfDay(for: calendar.date(from: calendar.dateComponents([.year, .month],
                                                                                                 from: now))!)
        let endOfMonth = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(day: -1),
                                                                to: startOfMonth)!)
        return PeriodDate(from: startOfMonth,
                          to: endOfMonth)
    }
    
    
}
