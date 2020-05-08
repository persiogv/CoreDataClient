//
//  CoreDataClient.swift
//  CoreDataClient
//
//  Created by Pérsio on 07/05/20.
//

import CoreData

/// CoreDataClient
public final class CoreDataClient {
    
    // MARK: Singleton
    
    /// A static instance of CoreDataClient
    public static let shared = CoreDataClient()
    
    private init() {
        provider = CoreDataProvider(container: NSPersistentContainer(name: ""))
    }
    
    // MARK: Properties
    
    private var provider: CoreDataProtocol
    
    // MARK: Setup
    
    /// Sets up the persistent container
    /// Note: call it before prior to any other methods
    /// - Parameters:
    ///   - container: A persistent container
    ///   - provider: A CoreDataProtocol adopter
    public static func with(container: NSPersistentContainer, provider: CoreDataProtocol? = nil) {
        shared.provider = provider ?? CoreDataProvider(container: container)
    }
}

// MARK: - Core data protocol
extension CoreDataClient: CoreDataProtocol {
    
    // MARK: Properties
    
    public final var newChildContext: NSManagedObjectContext {
        provider.newChildContext
    }
    
    // MARK: methods
    
    public final func create<T: NSManagedObject>(objectOfType type: T.Type, into context: NSManagedObjectContext? = nil) throws -> T {
        try provider.create(objectOfType: type, into: context)
    }
    
    public final func count<T: NSManagedObject>(objectsOfType type: T.Type,
                                                where predicate: NSPredicate?,
                                                within context: NSManagedObjectContext? = nil) throws -> Int {
        try provider.count(objectsOfType: type,
                           where: predicate,
                           within: context)
    }
    
    public final func select<T: NSManagedObject>(objectsOfType type: T.Type,
                                                 where predicate: NSPredicate? = nil,
                                                 sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
                                                 fetchLimit: Int = 0,
                                                 fetchOffset: Int = 0,
                                                 in context: NSManagedObjectContext? = nil,
                                                 completion: @escaping FetchingCompletion<T>) -> NSAsynchronousFetchRequest<T> {
        provider.select(objectsOfType: type,
                        where: predicate,
                        sortedBy: sortDescriptors,
                        fetchLimit: fetchLimit,
                        fetchOffset: fetchOffset,
                        in: context,
                        completion: completion)
    }
    
    public final func update<T: NSManagedObject>(object: T) throws -> T {
        try provider.update(object: object)
    }
    
    public final func delete<T: NSManagedObject>(objects: [T]) throws {
        try provider.delete(objects: objects)
    }
    
    public final func save() throws {
        try provider.save()
    }
}
