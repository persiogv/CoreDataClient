//
//  CoreDataProtocol.swift
//  CoreDataClient
//
//  Created by Pérsio on 07/05/20.
//

import CoreData

public protocol CoreDataProtocol {
    
    // MARK: Properties
    
    /// Creates and returns a new context from its parent context
    var newChildContext: NSManagedObjectContext { get }
    
    // MARK: Methods
        
    /// Creates a new object for the given type
    /// - Parameters:
    ///   - type: The object type
    ///   - context: If you are working on a child context, send it here
    /// - Throws: A CoreData error
    /// - Returns: A reference for the created new object
    func create<T: NSManagedObject>(objectOfType type: T.Type, into context: NSManagedObjectContext?) throws -> T
    
    /// Counts the existing objects for the given type and predicate
    /// - Parameters:
    ///   - type: The type of the objects to be counted
    ///   - predicate: A predicate to filter the results
    ///   - context: If you are working on a child context, send it here
    /// - Throws: A CoreData error
    /// - Returns: The count of the objects
    func count<T: NSManagedObject>(objectsOfType type: T.Type, where predicate: NSPredicate?, within context: NSManagedObjectContext?) throws -> Int
    
    /// Selects the objects of the given type and further parameters
    /// - Parameters:
    ///   - type: The objects type
    ///   - predicate: A predicate to filter the results
    ///   - sortDescriptors: Sort descriptors to organize the results
    ///   - fetchLimit: The results maximum count
    ///   - fetchOffset: The initial offset of the results
    ///   - context: If you are working on a child context, sent it here
    ///   - completion: Completion handler
    /// - Returns: A reference to the request created, so you can cancel it at anytime
    func select<T: NSManagedObject>(objectsOfType type: T.Type,
                                          where predicate: NSPredicate?,
                                          sortedBy sortDescriptors: [NSSortDescriptor]?,
                                          fetchLimit: Int,
                                          fetchOffset: Int,
                                          in context: NSManagedObjectContext?,
                                          completion: @escaping FetchingCompletion<T>) -> NSAsynchronousFetchRequest<T>
    
    /// Updates the given object
    /// Note: will be used the object's current context to save the changes
    /// - Parameter object: The object to be updated
    /// - Throws: A CoreData error
    /// - Returns: A reference to the updated object
    func update<T: NSManagedObject>(object: T) throws -> T
    
    /// Deletes the given objects
    /// Note: will be used the objects' current context to delete and save the changes
    /// - Parameter objects: The objects to be deleted
    /// - Throws: A CoreData error
    func delete<T: NSManagedObject>(objects: [T]) throws
    
    /// Saves the current changes of the current context
    /// Note: it may not save the child contexts
    /// - Throws: A CoreData error
    func save() throws
}
