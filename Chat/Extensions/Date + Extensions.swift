import Foundation

extension Date {
    
    init(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale
        let date = dateFormatter.date(from: dateString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }

    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        if Calendar.current.isDateInToday(self) {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "MMM, d"
        }
        return dateFormatter.string(from: self)
    }
    
    func onlyDayAndMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MMM, d"
        }
        return dateFormatter.string(from: self)    }
    
    func onlyHoursAndMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}
