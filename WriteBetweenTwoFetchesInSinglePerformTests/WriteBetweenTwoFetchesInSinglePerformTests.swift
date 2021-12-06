//
//  WriteBetweenTwoFetchesInSinglePerformTests.swift
//  WriteBetweenTwoFetchesInSinglePerformTests
//
//  Created by Nezhyborets Oleksii on 12/6/21.
//

import XCTest
@testable import WriteBetweenTwoFetchesInSinglePerform
import CoreData

class WriteBetweenTwoFetchesInSinglePerformTests: XCTestCase {
    private let stack = CoreDataTestStack.shared
    private var persistentContainer: NSPersistentContainer { stack.persistentContainer }
    private lazy var readContext = persistentContainer.newBackgroundContext()

    override func setUpWithError() throws {
        try stack.setup()
    }

    override func tearDownWithError() throws {
        try stack.teardown()
    }

    func testBlurredInfoUpdated() throws {
        let readExp = expectation(description: "read")
        performFetches {
            readExp.fulfill()
        }

        let writeExp = expectation(description: "write")
        performChangeAndSave {
            writeExp.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    private func performFetches(completion: @escaping () -> Void) {
        let moc = readContext
        moc.perform {
            let fetchRequest: NSFetchRequest<ManagedAsset> = ManagedAsset.fetchRequest()
            let count = try? moc.count(for: fetchRequest)
            let asset = try? moc.fetch(fetchRequest).first

            if count == 0 {
                XCTAssertNil(asset)
            } else if count == 1 {
                XCTAssertNotNil(asset)
            }

            completion()
        }
    }

    private func performChangeAndSave(completion: @escaping () -> Void) {
        let writeMoc = persistentContainer.newBackgroundContext()
        writeMoc.perform {
            _ = ManagedAsset(context: writeMoc)
            try! writeMoc.save()
            completion()
        }
    }
}
