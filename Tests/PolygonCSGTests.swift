//
//  PolygonCSGTests.swift
//  Euclid
//
//  Created by Nick Lockwood on 15/01/2023.
//  Copyright © 2023 Nick Lockwood. All rights reserved.
//

@testable import Euclid
import XCTest

class PolygonCSGTests: XCTestCase {
    // MARK: XOR

    func testXorCoincidingSquares() {
        let a = Polygon(shape: .square())!
        let b = Polygon(shape: .square())!
        let c = a.xor(b)
        XCTAssert(c.isEmpty)
    }

    func testXorAdjacentSquares() {
        let a = Polygon(shape: .square())!
        let b = a.translated(by: .unitX)
        let c = a.xor(b)
        XCTAssertEqual(Bounds(c), a.bounds.union(b.bounds))
    }

    func testXorOverlappingSquares() {
        let a = Polygon(shape: .square())!
        let b = a.translated(by: Vector(0.5, 0, 0))
        let c = a.xor(b)
        XCTAssertEqual(Bounds(c), Bounds(
            min: Vector(-0.5, -0.5, 0),
            max: Vector(1.0, 0.5, 0)
        ))
    }

    // MARK: Plane clipping

    func testSquareClippedToPlane() {
        let a = Polygon(shape: .square())!
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(Bounds(b), .init(Vector(0, -0.5), Vector(0.5, 0.5)))
    }

    func testPentagonClippedToPlane() {
        let a = Polygon(shape: .circle(segments: 5))!
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(Bounds(b), .init(
            Vector(0, -0.404508497187),
            Vector(0.475528258148, 0.5)
        ))
    }

    func testDiamondClippedToPlane() {
        let a = Polygon(shape: .circle(segments: 4))!
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.clip(to: plane)
        XCTAssertEqual(Bounds(b), .init(Vector(0, -0.5), Vector(0.5, 0.5)))
    }

    // MARK: Plane splitting

    func testSquareSplitAlongPlane() {
        let a = Polygon(shape: .square())!
        let plane = Plane(unchecked: .unitX, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(
            Bounds(b.0),
            .init(Vector(0, -0.5), Vector(0.5, 0.5))
        )
        XCTAssertEqual(
            Bounds(b.1),
            .init(Vector(-0.5, -0.5), Vector(0, 0.5))
        )
        XCTAssertEqual(b.front, b.0)
        XCTAssertEqual(b.back, b.1)
    }

    func testSquareSplitAlongItsOwnPlane() {
        let a = Polygon(shape: .square())!
        let plane = Plane(unchecked: .unitZ, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(b.front, [a])
        XCTAssert(b.back.isEmpty)
    }

    func testSquareSplitAlongReversePlane() {
        let a = Polygon(shape: .square())!
        let plane = Plane(unchecked: -.unitZ, pointOnPlane: .zero)
        let b = a.split(along: plane)
        XCTAssertEqual(b.back, [a])
        XCTAssert(b.front.isEmpty)
    }
}
