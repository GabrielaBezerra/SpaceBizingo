//
//  SpaceBizingoTests.swift
//  SpaceBizingoTests
//
//  Created by Gabriela Bezerra on 1/29/20.
//  Copyright © 2020 sharkberry. All rights reserved.
//

import XCTest
import SpriteKit

@testable import SpaceBizingo

class SpaceBizingoTests: XCTestCase {

    let board: Board = Board(amountOfRows: 8, scale: 43, yOrigin: 303)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTriangles() {
        
        let rowsCount = testAmountOfRows()
        
        for indexRow in 0...rowsCount-1 {
            
            let rowOfDatas = board.rowsData[indexRow]
            let rowOfNodes = board.rowsNodes[indexRow]
            
            let trianglesCount = testAmountOfTriangles(dataRow: rowOfDatas, nodeRow: rowOfNodes)
            
            
            for indexColumn in 0...trianglesCount-1 {
                
                let index = Index(x: indexRow, y: indexColumn)
                
                let triangleNode = board.rowsNodes[index.x][index.y]
                let triangleData = board.rowsData[index.x][index.y]
                
                testAnatomyOfTriangles(node: triangleNode, data: triangleData)
                
                testTriangleInitialEmptyState(data: triangleData)
                
                testTriangleHasBlueState(data: triangleData)
                testTriangleEmptyState(data: triangleData)
                testTriangleHasRedState(data: triangleData)
                testTriangleEmptyState(data: triangleData)
                testTriangleHasRedState(data: triangleData)
                testTriangleEmptyState(data: triangleData)
                
                testTriangleInitialEmptyState(data: triangleData)
            }
        }
    }
    
    func testAmountOfRows() -> Int {
        XCTAssertEqual(board.rowsData.count, board.rowsNodes.count)
        return board.rowsData.count
    }
    
    func testAmountOfTriangles(dataRow: [TriangleData], nodeRow: [SKShapeNode]) -> Int {
        XCTAssertEqual(dataRow.count, nodeRow.count)
        return dataRow.count
    }
    
    func testAnatomyOfTriangles(node: SKShapeNode, data: TriangleData) {
        XCTAssertEqual(node.reversed, data.opponent)
    }
    
    func testTriangleInitialEmptyState(data: TriangleData) {
        XCTAssertEqual(data.isEmpty, true)
        XCTAssertEqual(data.hasRed, false)
        XCTAssertEqual(data.hasBlue, false)
    }
    
    func testTriangleEmptyState(data: TriangleData) {
        data.setEmpty()
        XCTAssertEqual(data.isEmpty, true)
        XCTAssertEqual(data.hasRed, false)
        XCTAssertEqual(data.hasBlue, false)
    }
    
    func testTriangleHasBlueState(data: TriangleData) {
        data.setBlue()
        XCTAssertEqual(data.isEmpty, false)
        XCTAssertEqual(data.hasRed, false)
        XCTAssertEqual(data.hasBlue, true)
    }
    
    func testTriangleHasRedState(data: TriangleData) {
        data.setRed()
        XCTAssertEqual(data.isEmpty, false)
        XCTAssertEqual(data.hasRed, true)
        XCTAssertEqual(data.hasBlue, false)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            _ = Board(amountOfRows: 8, scale: 43, yOrigin: 303)
            // Put the code you want to measure the time of here.
        }
    }

}
