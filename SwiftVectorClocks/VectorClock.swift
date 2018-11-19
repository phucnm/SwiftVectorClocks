//
//  VectorClock.swift
//  SwiftVectorClocks
//
//  Created by TonyNguyen on 11/9/18.
//  Copyright © 2018 TonyNguyen. All rights reserved.
//


///Student Number: V00915696
///CSC564 Concurrency
import Foundation

enum CausallyOrdering {
  case equal
  case happensBefore
  case happensAfter
  case concurrent
}

class VectorClock: Equatable, Comparable {
  var v: [String: Int] = [:]

  init(clocks: [String: Int] = [:]) {
    v = clocks
  }

  // MARK: Custom Operators
  public static func ==(lhs: VectorClock, rhs: VectorClock) -> Bool {
    return lhs.v == rhs.v
  }

  public static func <(lhs: VectorClock, rhs: VectorClock) -> Bool {
    var strictlySmaller = false

    // I run two for loops because there maybe missing process in each vector
    for (_, pair) in lhs.v.enumerated() {
      let selfCounter = pair.value
      let rhsCounter = rhs.v[pair.key, default: 0]
      if selfCounter > rhsCounter {
        return false
      }
      strictlySmaller = strictlySmaller || (selfCounter < rhsCounter)
    }

    for (_, pair) in rhs.v.enumerated() {
      let selfCounter = lhs.v[pair.key, default: 0]
      let rhsCounter = pair.value
      if selfCounter > rhsCounter {
        return false
      }
      strictlySmaller = strictlySmaller || (selfCounter < rhsCounter)
    }

    return strictlySmaller
  }

  // MARK: Public Methods
  func increment(at pName: String) {
    v[pName] = v[pName, default: 0] + 1
  }

  func incremented(at pName: String) -> VectorClock {
    let vc = VectorClock(clocks: v)
    vc.increment(at: pName)
    return vc
  }

  func merge(with vc: VectorClock) -> VectorClock {
    var result = v
    vc.v.forEach { (pair) in
      result[pair.key] = max(result[pair.key, default: 0], pair.value)
    }
    return VectorClock(clocks: result)
  }

  func causallyOrder(to vc: VectorClock) -> CausallyOrdering {
    if self == vc {
      return .equal
    } else if self < vc {
      return .happensBefore
    } else if vc < self {
      return .happensAfter
    }
    return .concurrent
  }
}


