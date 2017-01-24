////
///  NilSafeEquals.swift
//

infix operator =?= : ComparisonPrecedence

func =?= <T>(lhs: Optional<T>, rhs: Optional<T>) -> Bool where T: Equatable {
    guard
        let lhs = lhs,
        let rhs = rhs
    else {
        return false
    }
    return lhs == rhs
}
func =?= <T>(lhs: T, rhs: Optional<T>) -> Bool where T: Equatable {
    guard
        let rhs = rhs
    else {
        return false
    }
    return lhs == rhs
}
func =?= <T>(lhs: Optional<T>, rhs: T) -> Bool where T: Equatable {
    guard
        let lhs = lhs
    else {
        return false
    }
    return lhs == rhs
}
func =?= <T>(lhs: T, rhs: T) -> Bool where T: Equatable {
    return lhs == rhs
}
