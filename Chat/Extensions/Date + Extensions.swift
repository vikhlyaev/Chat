import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd MMMM"
        }
        
        return dateFormatter.string(from: self)
    }
    
    func onlyHoursAndMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}
