import UIKit

extension UserDefaults {
    subscript<T>(key: String) -> T? where T: Codable {
        get {
            if let saved = self.object(forKey: key) as? Data {
                return try? JSONDecoder().decode(T.self, from: saved)
            }
            return nil
        }
        set {
            let encoder = JSONEncoder()
            if let value = newValue, let encoded = try? encoder.encode(value) {
                self.set(encoded, forKey: key)
            } else {
                self.removeObject(forKey: key)
            }
        }
    }
    
    subscript(key: String) -> Any? {
        get {
            fatalError("only for remove object")
        }
        set {
            self.removeObject(forKey: key)
        }
    }
}
