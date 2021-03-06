//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A set of unique elements as determined by `hashValue` and `==`.
public struct Set<Element: Hashable>: ArrayLiteralConvertible, ExtensibleCollectionType, Hashable, Printable, DebugPrintable {

	// MARK: Constructors

	/// Constructs a `Set` with the elements of `sequence`.
	public init<S: SequenceType where S.Generator.Element == Element>(_ sequence: S) {
		self.init(values: [:])
		extend(sequence)
	}

	/// Constructs a `Set` from a variadic parameter list.
	public init(_ elements: Element...) {
		self.init(elements)
	}

	/// Constructs the empty `Set`.
	public init() {
		self.init(values: [:])
	}

	/// Constructs an empty `Set` with a hint as to the capacity it should allocate.
	public init(minimumCapacity: Int) {
		self.init(values: [Element: Unit](minimumCapacity: minimumCapacity))
	}


	// MARK: Properties

	/// The number of entries in the receiver.
	public var count: Int {
		return values.count
	}

	/// True iff `count` is 0.
	public var isEmpty: Bool {
		return values.isEmpty
	}


	// MARK: Primitive operations

	/// True iff `element` is in the receiver, as defined by its hash and equality.
	public func contains(element: Element) -> Bool {
		return values[element] != nil
	}

	/// Retrieve an arbitrary element & insert with empty subscript.
	public subscript(v: ()) -> Element {
		get { return values[values.startIndex].0 }
		set { insert(newValue) }
	}

	/// Inserts `element` into the receiver, if it doesn’t already exist.
	public mutating func insert(element: Element) {
		values[element] = Unit()
	}

	/// Removes `element` from the receiver, if it’s a member.
	public mutating func remove(element: Element) {
		values.removeValueForKey(element)
	}

	/// Removes all elements from the receiver.
	public mutating func removeAll() {
		values = [:]
	}


	// MARK: Algebraic operations

	/// Returns the union of the receiver and `set`.
	public func union(set: Set) -> Set {
		return self + set
	}

	/// Returns the intersection of the receiver and `set`.
	public func intersection(set: Set) -> Set {
		return count <= set.count ?
			filter { set.contains($0) }
		:	set.filter { self.contains($0) }
	}

	/// Returns the relative complement of `set` in `self`.
	///
	/// This is a new set with all elements from the receiver which are not contained in `set`.
	public func complement(set: Set) -> Set {
		return filter { !set.contains($0) }
	}

	/// Returns the symmetric difference of `self` and `set`.
	///
	/// This is a new set with all elements that exist only in `self` or `set`, and not both.
	public func difference(set: Set) -> Set {
		return union(set) - intersection(set)
	}


	// MARK: Set inclusion functions

	/// True iff the receiver is a subset of (is included in) `set`.
	public func subset(set: Set) -> Bool {
		return complement(set) == Set()
	}

	/// True iff the receiver is a subset of but not equal to `set`.
	public func strictSubset(set: Set) -> Bool {
		return subset(set) && self != set
	}

	/// True iff the receiver is a superset of (includes) `set`.
	public func superset(set: Set) -> Bool {
		return set.subset(self)
	}

	/// True iff the receiver is a superset of but not equal to `set`.
	public func strictSuperset(set: Set) -> Bool {
		return set.strictSubset(self)
	}


	// MARK: Higher-order functions

	/// Returns a new set including only those elements `x` where `includeElement(x)` is true.
	public func filter(includeElement: Element -> Bool) -> Set {
		return Set(lazy(self).filter(includeElement))
	}

	/// Returns a new set with the result of applying `transform` to each element.
	public func map<Result>(transform: Element -> Result) -> Set<Result> {
		return flatMap { [transform($0)] }
	}

	/// Applies `transform` to each element and returns a new set which is the union of each resulting set.
	public func flatMap<Result, S: SequenceType where S.Generator.Element == Result>(transform: Element -> S) -> Set<Result> {
		return reduce([]) { $0 + transform($1) }
	}

	/// Combines each element of the receiver with an accumulator value using `combine`, starting with `initial`.
	public func reduce<Into>(initial: Into, combine: (Into, Element) -> Into) -> Into {
		return Swift.reduce(self, initial, combine)
	}


	// MARK: ArrayLiteralConvertible

	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<Element> {
		return GeneratorOf(values.keys.generate())
	}


	// MARK: CollectionType

	public typealias Index = DictionaryIndex<Element, Unit>

	public var startIndex: Index {
		return values.startIndex
	}

	public var endIndex: Index {
		return values.endIndex
	}

	public subscript(index: Index) -> Element {
		return values[index].0
	}


	// MARK: ExtensibleCollectionType

	/// In theory, reserve capacity for `n` elements. However, `Dictionary` does not implement `reserveCapacity`, so we just silently ignore it.
	public func reserveCapacity(n: Set.Index.Distance) {}

	/// Inserts each element of `sequence` into the receiver.
	public mutating func extend<S: SequenceType where S.Generator.Element == Element>(sequence: S) {
		// Note that this should just be for each in sequence; this is working around a compiler bug.
		for each in SequenceOf<Element>(sequence) {
			insert(each)
		}
	}

	/// Appends `element` onto the `Set`.
	public mutating func append(element: Element) {
		insert(element)
	}


	// MARK: Hashable

	/// Hashes using Bob Jenkins’ one-at-a-time hash.
	///
	/// http://en.wikipedia.org/wiki/Jenkins_hash_function#one-at-a-time
	///
	/// NB: Jenkins’ usage appears to have been string keys; the usage employed here seems similar but may have subtle differences which have yet to be discovered.
	public var hashValue: Int {
		return hashValues(self)
	}


	// MARK: Printable

	public var description: String {
		return describe(self)
	}


	// MARK: DebugPrintable
	
	public var debugDescription: String {
		return debugDescribe(self)
	}
	

	// MARK: Private

	/// Constructs a `Set` with a dictionary of `values`.
	private init(values: [Element: Unit]) {
		self.values = values
	}

	/// The underlying dictionary.
	private var values: [Element: Unit]
}


// MARK: - Operators

/// Extends a `set` with the elements of a `sequence`.
public func += <S: SequenceType> (inout set: Set<S.Generator.Element>, sequence: S) {
	set.extend(sequence)
}


/// Returns a new set with all elements from `set` which are not contained in `other`.
public func - <Element> (set: Set<Element>, other: Set<Element>) -> Set<Element> {
	return set.complement(other)
}

/// Removes all elements in `other` from `set`.
public func -= <Element> (inout set: Set<Element>, other: Set<Element>) {
	set = set.complement(other)
}


/// Intersects with `set` with `other`.
public func &= <Element> (inout set: Set<Element>, other: Set<Element>) {
	set = set.intersection(other)
}

/// Returns the intersection of `set` and `other`.
public func & <Element> (set: Set<Element>, other: Set<Element>) -> Set<Element> {
	return set.intersection(other)
}


/// Defines equality for sets of equatable elements.
public func == <Element> (a: Set<Element>, b: Set<Element>) -> Bool {
	return a.values == b.values
}
