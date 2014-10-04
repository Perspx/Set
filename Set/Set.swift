//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A set of unique elements.
public struct Set<Element : Hashable> {
	/// Initializes with the elements of `sequence`.
	public init<S : SequenceType where S.Generator.Element == Element>(_ sequence: S) {
		self.init(values: [:])
		extend(sequence)
	}

	/// Initializes an empty set.
	public init() {
		self.init(values: [:])
	}

	/// Initializes an empty set with at least `minimumCapacity` worth of storage.
	public init(minimumCapacity: Int) {
		self.init(values: [Element: Unit](minimumCapacity: minimumCapacity))
	}


	/// The number of entries in the set.
	public var count: Int { return values.count }

	/// True iff `count == 0`.
	public var isEmpty: Bool {
		return self.values.isEmpty
	}


	public func contains(element: Element) -> Bool {
		return values[element] != nil
	}
	
	public mutating func insert(element: Element) {
		values[element] = Unit()
	}
	
	public mutating func remove(element: Element) {
		values.removeValueForKey(element)
	}


	/// Initialize a Set with a dictionary of elements to unit.
	///
	/// For the private use of the other initializers.
	private init(values: [Element: Unit]) {
		self.values = values
	}

	private var values = [Element: Unit]()
}


/// SequenceType conformance.
extension Set : SequenceType {
	public func generate() -> GeneratorOf<Element> {
		var generator = values.keys.generate()
		return GeneratorOf {
			return generator.next()
		}
	}
}


/// CollectionType conformance.
extension Set : CollectionType {
	public typealias IndexType = DictionaryIndex<Element, Unit>
	public var startIndex: IndexType { return values.startIndex }
	public var endIndex: IndexType { return values.endIndex }
	
	public subscript(v: ()) -> Element {
	get { return values[values.startIndex].0 }
	set { insert(newValue) }
	}
	
	public subscript(index: IndexType) -> Element {
		return values[index].0
	}
}

/// ExtensibleCollectionType conformance.
extension Set : ExtensibleCollectionType {
	/// In theory, reserve capacity for \c n elements. However, Dictionary does not implement reserveCapacity(), so we just silently ignore it.
	public func reserveCapacity(n: IndexType.Distance) {}
	
	/// Inserts each element of \c sequence into the receiver.
	public mutating func extend<S : SequenceType where S.Generator.Element == Element>(sequence: S) {
		// Note that this should just be for each in sequence; this is working around a compiler crasher.
		for each in [Element](sequence) {
			insert(each)
		}
	}

	public mutating func append(element: Element) {
		insert(element)
	}
}


/// Extends /c set with the elements of /c sequence.
public func += <S : SequenceType> (inout set: Set<S.Generator.Element>, sequence: S) {
	set.extend(sequence)
}


/// ArrayLiteralConvertible conformance.
extension Set : ArrayLiteralConvertible {
	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}


/// Defines equality for sets of equatable elements.
public func == <Element : Hashable> (a: Set<Element>, b: Set<Element>) -> Bool {
	return a.values == b.values
}


/// Set is reducible.
extension Set {
	public func reduce<Into>(initial: Into, combine: (Into, Element) -> Into) -> Into {
		return Swift.reduce(self, initial, combine)
	}
}


/// Printable conformance.
extension Set : Printable {
	public var description: String {
		if self.count == 0 { return "{}" }
		
		let joined = join(", ", map(self) { toString($0) })
		return "{ \(joined) }"
	}
}


/// Hashable conformance.
///
/// This hash function has not been proven in this usage, but is based on Bob Jenkins’ one-at-a-time hash.
extension Set : Hashable {
	public var hashValue: Int {
		var h = reduce(0) { into, each in
			var h = into + each.hashValue
			h += (h << 10)
			h ^= (h >> 6)
			return h
		}
		h += (h << 3)
		h ^= (h >> 11)
		h += (h << 15)
		return h
	}
}
