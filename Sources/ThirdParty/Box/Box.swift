//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// Wraps a type `T` in a reference type.
///
/// Typically this is used to work around limitations of value types (for example, the lack of codegen for recursive value types and type-parameterized enums with >1 case). It is also useful for sharing a single (presumably large) value without copying it.
final class Box<T>: BoxType, CustomStringConvertible {
	/// Initializes a `Box` with the given value.
	init(_ value: T) {
		self.value = value
	}


	/// Constructs a `Box` with the given `value`.
	class func unit(_ value: T) -> Box<T> {
		return Box(value)
	}


	/// The (immutable) value wrapped by the receiver.
	let value: T

	/// Constructs a new Box by transforming `value` by `f`.
	func map<U>(_ f: (T) -> U) -> Box<U> {
		return Box<U>(f(value))
	}


	// MARK: Printable

	var description: String {
		return String(describing: value)
	}
}
