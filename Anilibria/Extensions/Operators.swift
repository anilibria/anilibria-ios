infix operator >>
public func >> <T>(value: Any?, toType: T.Type) -> T? {
    return value as? T
}

precedencegroup MappingPrecedence {
    associativity: right
}

infix operator <-: MappingPrecedence
public func <- <V>(value: inout V, other: V?) {
    if let other = other {
        value = other
    }
}

public func <- <V, C: Converter>(value: V, converter: C) -> C.ToValue where V == C.FromValue {
    return converter.convert(from: value)
}

postfix operator |
public postfix func | <V>(value: V) -> V.Type {
    return V.self
}
