import Foundation

public protocol Formatting {
    func string(from: Any?) -> String?
    func reverse(from: String) -> Any?
}

extension Formatting {
    public func reverse(from: String) -> Any? {
        return nil
    }
}

public typealias Formatter = (Any?) -> String?
public typealias ReverseFormatter = (String) -> Any?

public enum FormatterFactory {
    case time
    case date(String)

    func create() -> Formatting {
        switch self {
        case .date(let format):
            return DateFormatter(format)
        case .time:
            return TimeFormatter()
        }
    }
}

private class TimeFormatter: Formatting {
    func string(from: Any?) -> String? {
        var seconds: Int?
        
        if let value = from as? Double {
            seconds = Int(value)
        } else if let value = from as? Float {
            seconds = Int(value)
        }
        
        guard let sec = seconds else {
            return nil
        }
        
        let ss = sec % 60
        var mm = sec / 60
        let hh = mm / 60
        
        if mm > 59 {
            mm = mm % 60
        }
        
        if hh > 0 {
            return String(format: "%02d:%02d:%02d", hh, mm, ss)
        }
        
        return String(format: "%02d:%02d", mm, ss)
    }
    
    func reverse(from: String) -> Any? {
        return nil
    }
}

extension DateFormatter: Formatting {
    
    convenience public init(_ format: String) {
        self.init()
        self.dateFormat = format
    }
    
    public func string(from: Any?) -> String? {
        guard let value = from as? Date else {
            return nil
        }
        
        return self.string(from: value)
    }
}
