import Foundation
import EmptiableTypes
import MonoidTypes
import WrappedTypes

@propertyWrapper
public struct Restrict<T: WrappedType> {
    public var wrappedValue: T {
        didSet { restrict(&wrappedValue) }
    }
    private let restrict: (inout T) -> Void
    public init(_ wrappedValue: T, _ restrict: @escaping (inout T) -> Void) {
        self.wrappedValue = wrappedValue
        self.restrict = restrict
        self.restrict(&self.wrappedValue)
    }
}

extension Restrict where T: MonoidType {
    public init(_ restrict: @escaping (inout T) -> Void) {
        self.init(T.identity, restrict)
    }
}

public typealias NilIfZero = NilIfEmpty

@propertyWrapper
public struct NilIfEmpty<T: NilableType & EmptiableType> {
    public var wrappedValue: T {
        didSet {
            if wrappedValue.isEmpty {
                wrappedValue.setToNil()
            }
        }
    }

    public init(_ wrappedValue: T) {
        self.wrappedValue = wrappedValue
        if self.wrappedValue.isEmpty {
            self.wrappedValue.setToNil()
        }
    }
}

@propertyWrapper
public struct WithinRange<T: WrappedType> where T.WrappedValue: Numeric, T.WrappedValue: Comparable {
    public var wrappedValue: T {
        get { restriction.wrappedValue }
        set { restriction.wrappedValue = newValue }
    }
    private var restriction: Restrict<T>

    public init(_ wrappedValue: T, _ range: ClosedRange<T.WrappedValue>) {
        restriction = .init(wrappedValue) {
            $0.wrappedValue = min(range.upperBound, max(range.lowerBound, $0.wrappedValue))
        }
    }
}

extension WithinRange where T: MonoidType {
    public init(_ range: ClosedRange<T.WrappedValue>) {
        self.init(T.identity, range)
    }
}

@propertyWrapper
public struct Truncated<T: WrappedType> where T.WrappedValue: RangeReplaceableCollection {
    public var wrappedValue: T {
        get { restriction.wrappedValue }
        set { restriction.wrappedValue = newValue }
    }
    private var restriction: Restrict<T>

    public init(_ wrappedValue: T, maxLength: Int) {
        restriction = .init(wrappedValue) {
            $0.wrappedValue = T.WrappedValue($0.wrappedValue.prefix(maxLength))
        }
    }
}

extension Truncated where T: MonoidType {
    public init(maxLength: Int) {
        self.init(T.identity, maxLength: maxLength)
    }
}

@propertyWrapper
public struct RegEx<T: WrappedType> where T.WrappedValue == String {
    public var wrappedValue: T {
        didSet {
            if !validation(wrappedValue.wrappedValue) {
                wrappedValue = oldValue
            }
        }
    }
    private let validation: (String) -> Bool

    public init(_ wrappedValue: T, _ regex: String) {
        self.wrappedValue = wrappedValue
        validation = { candidate in
            NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: candidate)
        }
    }
}

extension RegEx where T: MonoidType {
    public init(_ regex: String) {
        self.init(T.identity, regex)
    }
}

@propertyWrapper
public struct UserDefault<T: WrappedType> {
    let key: String
    let defaultValue: T
    let container: UserDefaults

    public init(key: String, defaultValue: T, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }

    public var wrappedValue: T {
        get { container.object(forKey: key) as? T ?? defaultValue }
        set {
            if let optional = newValue as? NilableType, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }

    public var projectedValue: UserDefault<T> {
        self
    }
}

extension UserDefault where T: MonoidType {
    public init(key: String, container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: T.identity, container: container)
    }
}
