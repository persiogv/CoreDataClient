//
//  Common.swift
//  CoreDataClient
//
//  Created by Pérsio on 07/05/20.
//

import CoreData

/// Fetching completion handler typealias
public typealias FetchingCompletion<T: NSManagedObject> = (Result<[T], Error>) -> Void

/// Errors enum
public enum CoreDataClientError: Error {
    case couldNotCreateObject
}
