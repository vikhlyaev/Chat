import Foundation

extension String {
    func toData() -> Data {
        Data(self.utf8)
    }
}
