import Foundation

extension Array where Element: DayCategorizable {
    var daySorted: [Date: [Element]] {
        var result: [Date: [Element]] = [:]
        let calendar = Calendar.current
        forEach { item in
            let startOfDay = calendar.startOfDay(for: item.date)
            if result.keys.contains(startOfDay) {
                result[startOfDay]?.append(item)
            } else {
                result[startOfDay] = [item]
            }
        }
        return result
    }
}
