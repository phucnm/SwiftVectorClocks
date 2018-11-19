//
//  SVCTests.swift
//  SVCTests
//
//  Created by TonyNguyen on 11/9/18.
//  Copyright © 2018 TonyNguyen. All rights reserved.
//

///Student Number: V00915696
///CSC564 Concurrency
import XCTest

class SVCTests: XCTestCase {

  var vc1 = VectorClock()
  var vc2 = VectorClock()

  override func setUp() {
    vc1 = VectorClock()
    vc2 = VectorClock()
  }

  override func tearDown() {

  }

  func testEmptyClock() {
    XCTAssertEqual(vc1, vc2)
    XCTAssertEqual(vc1.causallyOrder(to: vc2), .equal)
    XCTAssertEqual(vc2.causallyOrder(to: vc1), .equal)
  }

  func testIncrementOnce() {
    vc2.increment(at: "p1")
    XCTAssertEqual(vc1.causallyOrder(to: vc2), .happensBefore)
    XCTAssertEqual(vc2.causallyOrder(to: vc1), .happensAfter)
  }
  func testConcurrent() {
    vc1.increment(at: "p1")
    vc2.increment(at: "p2")
    XCTAssertEqual(vc1.causallyOrder(to: vc2), .concurrent)
    XCTAssertEqual(vc2.causallyOrder(to: vc1), .concurrent)
  }
  func testMerge() {
    vc1.increment(at: "p1")
    vc2.increment(at: "p2")
    let vc3 = vc1.merge(with: vc2)
    XCTAssertEqual(vc3, VectorClock(clocks: ["p1": 1, "p2": 1]))
    XCTAssertEqual(vc1.causallyOrder(to: vc2), .concurrent)
    XCTAssertEqual(vc1.causallyOrder(to: vc3), .happensBefore)
    XCTAssertEqual(vc2.causallyOrder(to: vc3), .happensBefore)
  }
  func testVersusWiki() {
    let c1 = VectorClock().incremented(at: "C")
    let b1 = VectorClock().merge(with: c1).incremented(at: "B")
    let b2 = b1.incremented(at: "B")
    let a1 = VectorClock().merge(with: b2).incremented(at: "A")
    let a2 = a1.incremented(at: "A")
    let b3 = b2.incremented(at: "B")
    let b4 = a2.merge(with: b3).incremented(at: "B")
    let c2 = b3.merge(with: c1).incremented(at: "C")
    let b5 = b4.incremented(at: "B")
    let c3 = c2.incremented(at: "C")
    let c4 = b5.merge(with: c3).incremented(at: "C")
    let c5 = c4.incremented(at: "C")
    let a3 = c3.merge(with: a2).incremented(at: "A")
    let a4 = c5.merge(with: a3).incremented(at: "A")
    XCTAssertEqual(a1, VectorClock(clocks: ["A": 1, "B": 2, "C": 1]))
    XCTAssertEqual(a2, VectorClock(clocks: ["A": 2, "B": 2, "C": 1]))
    XCTAssertEqual(a3, VectorClock(clocks: ["A": 3, "B": 3, "C": 3]))
    XCTAssertEqual(a4, VectorClock(clocks: ["A": 4, "B": 5, "C": 5]))
    XCTAssertEqual(b1, VectorClock(clocks: ["B": 1, "C": 1]))
    XCTAssertEqual(b2, VectorClock(clocks: ["B": 2, "C": 1]))
    XCTAssertEqual(b3, VectorClock(clocks: ["B": 3, "C": 1]))
    XCTAssertEqual(b4, VectorClock(clocks: ["A": 2, "B": 4, "C": 1]))
    XCTAssertEqual(b5, VectorClock(clocks: ["A": 2, "B": 5, "C": 1]))
    XCTAssertEqual(c1, VectorClock(clocks: ["C": 1]))
    XCTAssertEqual(c2, VectorClock(clocks: ["B": 3, "C": 2]))
    XCTAssertEqual(c3, VectorClock(clocks: ["B": 3, "C": 3]))
    XCTAssertEqual(c4, VectorClock(clocks: ["A": 2, "B": 5, "C": 4]))
    XCTAssertEqual(c5, VectorClock(clocks: ["A": 2, "B": 5, "C": 5]))
  }
}
