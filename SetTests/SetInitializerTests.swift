//  Copyright (c) 2014 Rob Rix. All rights reserved.

import XCTest
import Set

final class SetInitializerTests: XCTestCase {
	func testVariadic() {
		XCTAssert(Set(1) == Set([1]))
		XCTAssert(Set(1, 2, 3) == Set([1, 2, 3]))
	}

	func testMinimumCapacity() {
		XCTAssert(Set<Int>(minimumCapacity: 4).isEmpty)
	}
}
