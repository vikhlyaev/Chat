import Foundation

extension Array where Element: DayCategorizable {
    var daySorted: [Date: [Element]] {
        var result: [Date: [Element]] = [:]
        let calendar = Calendar.current
        forEach { item in
            let i = calendar.startOfDay(for: item.date)
            if result.keys.contains(i) {
                result[i]?.append(item)
            } else {
                result[i] = [item]
            }
        }
        return result
    }
}
