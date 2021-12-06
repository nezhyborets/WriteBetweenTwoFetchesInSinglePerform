//
//  CoreDataTestStack.swift
//  BeminiTests
//
//  Created by Nezhyborets Oleksii on 2/12/20.
//  Copyright © 2020 MacPaw Labs. All rights reserved.
//

import CoreData

final class CoreDataTestStack {
    static let shared = CoreDataTestStack()

    static private let mom: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataTestStack.self)
        return NSManagedObjectModel.mergedModel(from: [bundle])!
    }()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "QueryGenerationForInconsistencyFix",
            managedObjectModel: CoreDataTestStack.mom
        )
        return container
    }()

    private init() {}

    func setup() throws {
        try destroy()
        try load()
    }

    func teardown() throws {
        try destroy()
    }

    private var storeCoordinator: NSPersistentStoreCoordinator {
        persistentContainer.persistentStoreCoordinator
    }

    private func load() throws {
        var setupError: Error?
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if error != nil {
                setupError = error
            }
        }
        if let setupError = setupError {
            throw setupError
        }
    }

    private func destroy() throws {
        let storeCoordinator = persistentContainer.persistentStoreCoordinator
        try persistentContainer.persistentStoreDescriptions.forEach { storeDescription in
            try storeCoordinator.destroyPersistentStore(
                at: storeDescription.url!,
                ofType: storeDescription.type,
                options: nil
            )
            let stillExists = !FileManager.default.fileExists(atPath: storeDescription.url!.path)
            assert(!stillExists)
        }
    }
}
