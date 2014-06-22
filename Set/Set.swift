//  Copyright (c) 2014 Rob Rix. All rights reserved.

struct Set<Element : Hashable> {
	var _dictionary: Dictionary<Element, Void> = [:]
}

extension Set {
	init<S : Sequence where S.GeneratorType.Element == Element>(_ sequence: S) {
		extend(sequence)
	}
	
	
	func contains(element: Element) -> Bool {
		return _dictionary[element].getLogicValue()
	}
	
	mutating func insert(element: Element) {
		_dictionary[element] = ()
	}
	
	mutating func remove(element: Element) {
		_dictionary.removeValueForKey(element)
	}
}

extension Set : Sequence {
	func generate() -> MapSequenceGenerator<Dictionary<Element, Void>.GeneratorType, Element> {
		return _dictionary.keys.generate()
	}
}


extension Set {
	typealias IndexType = DictionaryIndex<Element, Void>
	var startIndex: IndexType { return _dictionary.startIndex }
	var endIndex: IndexType { return _dictionary.endIndex }
	
	subscript(index: IndexType) -> Element {
		let (element, _) = _dictionary[index]
		return element
	}
}

extension Set {
	func reserveCapacity(n: IndexType.DistanceType) {}
	
	mutating func extend<S : Sequence where S.GeneratorType.Element == Element>(sequence: S) {
		for each in Element[](sequence) {
			insert(each)
		}
	}
}


extension Set : ArrayLiteralConvertible {
	static func convertFromArrayLiteral(elements: Element...) -> Set<Element> {
		return Set(elements)
	}
}
