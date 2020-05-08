//
//  CoreDataProvider.swift
//  CoreDataClient
//
//  Created by Pérsio on 03/05/20.
//

import CoreData

final class CoreDataProvider {
    
    // MARK: Properties
    
    private let container: NSPersistentContainer
    
    private lazy var context: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    
    // MARK: Initializer
    
    required init(container: NSPersistentContainer) {
        self.container = container
    }
}

// MARK: - Core data protocol
extension CoreDataProvider: CoreDataProtocol {
    
    // MARK: Public properties
    
    final var newChildContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.context
        return context
    }
    
    // MARK: Public methods
    
    final func create<T: NSManagedObject>(objectOfType type: T.Type, into context: NSManagedObjectContext? = nil) throws -> T {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: type), into: context ?? self.context) as? T else {
            throw CoreDataClientError.couldNotCreateObject
        }
        
        return object
    }
    
    final func count<T: NSManagedObject>(objectsOfType type: T.Type, where predicate: NSPredicate?, within context: NSManagedObjectContext? = nil) throws -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        
        return try (context ?? self.context).count(for: request)
    }
    
    final func select<T: NSManagedObject>(objectsOfType type: T.Type,
                                          where predicate: NSPredicate? = nil,
                                          sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
                                          fetchLimit: Int = 0,
                                          fetchOffset: Int = 0,
                                          in context: NSManagedObjectContext? = nil,
                                          completion: @escaping FetchingCompletion<T>) -> NSAsynchronousFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = fetchLimit
        request.fetchOffset = fetchOffset
        
        let asyncRequest = NSAsynchronousFetchRequest<T>(fetchRequest: request) { result in
            guard let finalResult = result.finalResult else { return completion(.success([])) }
            completion(.success(finalResult))
        }
        
        do {
            try (context ?? self.context).execute(asyncRequest)
        } catch {
            completion(.failure(error))
        }
        
        return asyncRequest
    }
    
    final func update<T: NSManagedObject>(object: T) throws -> T {
        if object.hasChanges {
            try object.managedObjectContext?.save()
        }
        
        return object
    }
    
    final func delete<T: NSManagedObject>(objects: [T]) throws {
        try objects.forEach { object in
            if let context = object.managedObjectContext {
                context.delete(object)
                try context.save()
            }
        }
    }
    
    final func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
