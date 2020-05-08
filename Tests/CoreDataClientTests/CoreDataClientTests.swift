import XCTest
import CoreData
@testable import CoreDataClient

// MARK: - Core Data Managed Objects

final class Author: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged public var publications: Set<Publication>?
}

class Publication: NSManagedObject {
    @NSManaged var publicationDate: Date?
    @NSManaged var numberOfViews: Int64
    @NSManaged var author: Author?
}

final class Story: Publication {
    @NSManaged var videoURL: URL?
}

final class Article: Publication {
    @NSManaged var text: String?
}

// MARK: - Tests

final class CoreDataClientTests: XCTestCase {
    
    var client: CoreDataProvider!
    
    override func setUp() {
        super.setUp()
        
        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: "Author",
                    managedObjectClass: Author.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "name", type: .stringAttributeType)
                    ],
                    relationships: [
                        .relationship(name: "publications", destination: "Publication", toMany: true, deleteRule: .cascadeDeleteRule, inverse: "author")
                    ],
                    indexes: [
                        .index(name: "byName", elements: [ .property(name: "name") ])
                ]),
                .entity(
                    name: "Publication",
                    managedObjectClass: Publication.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "publicationDate", type: .dateAttributeType),
                        .attribute(name: "numberOfViews", type: .integer64AttributeType, isOptional: true)
                    ],
                    relationships: [
                        .relationship(name: "author", destination: "Author", toMany: false, inverse: "publications")
                ]),
                .entity(
                    name: "Story",
                    managedObjectClass: Story.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "videoURL", type: .URIAttributeType)
                ]),
                .entity(
                    name: "Article",
                    managedObjectClass: Article.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "text", type: .stringAttributeType)
                ])
            ]
        )
        
        let container = makePersistentContainer(name: "CoreDataModelDescriptionTest", modelDescription: modelDescription)
        client = CoreDataProvider(container: container)
    }
    
    func testInsertingAndCountingData() {
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            let count = try client.count(objectsOfType: Author.self, where: nil)
            XCTAssertEqual(count, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testUpdatingData() {
        let expectation = XCTestExpectation()
        
        do {
            var author = try client.create(objectOfType: Author.self)
            author.name = "Pérsio"
            
            try client.save()
            
            author.name = "Mari"
            
            author = try client.update(object: author)
            
            _ = client.select(objectsOfType: Author.self, where: nil, sortedBy: nil, fetchLimit: 1, fetchOffset: 0, completion: { result in
                switch result {
                case .success(let authors):
                    XCTAssertEqual(authors.first?.name, "Mari")
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            })
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeletingData() {
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            var count = try client.count(objectsOfType: Author.self, where: nil)
            XCTAssertEqual(count, 2)
            
            try client.delete(objects: [mari])
            
            count = try client.count(objectsOfType: Author.self, where: nil)
            XCTAssertEqual(count, 1)
            
            try client.delete(objects: [persio])
            
            count = try client.count(objectsOfType: Author.self, where: nil)
            XCTAssertEqual(count, 0)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFilteringData() {
        let expectation = XCTestExpectation()
        
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            let predicate = NSPredicate(format: "name == %@", "Pérsio")
            
            _ = client.select(objectsOfType: Author.self, where: predicate, sortedBy: nil) { result in
                switch result {
                case .success(let authors):
                    XCTAssertEqual(authors.first?.name, persio.name)
                    XCTAssertEqual(authors.count, 1)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testOffsettingData() {
        let expectation = XCTestExpectation()
        
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            _ = client.select(objectsOfType: Author.self, where: nil, sortedBy: [name], fetchLimit: 0, fetchOffset: 1) { result in
                switch result {
                case .success(let authors):
                    XCTAssertEqual(authors.first?.name, persio.name)
                    XCTAssertEqual(authors.count, 1)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testLimitingData() {
        let expectation = XCTestExpectation()
        
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            _ = client.select(objectsOfType: Author.self, where: nil, sortedBy: [name], fetchLimit: 1, fetchOffset: 0) { result in
                switch result {
                case .success(let authors):
                    XCTAssertEqual(authors.first?.name, mari.name)
                    XCTAssertEqual(authors.count, 1)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testSelectingData() {
        let expectation = XCTestExpectation()
        
        do {
            let persio = try client.create(objectOfType: Author.self)
            persio.name = "Pérsio"
            
            let mari = try client.create(objectOfType: Author.self)
            mari.name = "Mari"
            
            try client.save()
            
            let name = NSSortDescriptor(key: "name", ascending: true)
            
            _ = client.select(objectsOfType: Author.self, where: nil, sortedBy: [name]) { result in
                switch result {
                case .success(let authors):
                    XCTAssertEqual(authors.first?.name, mari.name)
                    XCTAssertEqual(authors.last?.name, persio.name)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 1)
    }
}

private extension XCTestCase {
    
    func makePersistentContainer(name: String, modelDescription: CoreDataModelDescription, configurations: [String]? = nil) -> NSPersistentContainer {
        let model = modelDescription.makeModel()
        
        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
        
        let persistentStoreDescriptions: [NSPersistentStoreDescription]
        if let configurations = configurations {
            persistentStoreDescriptions =
                configurations.map { (configurationName) in
                    let persistentStoreDescription = NSPersistentStoreDescription()
                    persistentStoreDescription.type = NSInMemoryStoreType
                    persistentStoreDescription.configuration = configurationName
                    //Need to set URL for distinction, even for Type NSInMemoryStoreType
                    persistentStoreDescription.url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(configurationName).appendingPathExtension("sqlite")
                    return persistentStoreDescription
            }
        } else {
            let persistentStoreDescription = NSPersistentStoreDescription()
            persistentStoreDescription.type = NSInMemoryStoreType
            persistentStoreDescriptions = [persistentStoreDescription]
        }
        
        persistentContainer.persistentStoreDescriptions = persistentStoreDescriptions
        
        let loadPersistentStoresExpectation = expectation(description: "Persistent container expected to load the store")
        
        var loadedPersistentStoresCount = 0
        
        persistentContainer.loadPersistentStores { description, error in
            XCTAssertNil(error)
            guard let configurations = configurations else {
                loadPersistentStoresExpectation.fulfill()
                return
            }
            loadedPersistentStoresCount += 1
            if loadedPersistentStoresCount == configurations.count {
                loadPersistentStoresExpectation.fulfill()
            }
        }
        
        wait(for: [loadPersistentStoresExpectation], timeout: 0.1)
        
        return persistentContainer
    }
}
