//
//  TaskController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!

class TaskController {
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    init() {
        fetchTasksFromServer()
    }
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch")
                completion(.failure(.noData))
                return
            }
            
            do {
                let taskRepresentations = Array(try JSONDecoder().decode([String : TaskRepresentation].self, from: data).values)
                try self.updateTasks(with: taskRepresentations)
                completion(.success(true))
            } catch {
                NSLog("Error decoding tasks from server: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }
    
    func sendTaskToServer(task: Task, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = task.taskRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task \(task): \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Error sending task to server: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func deleteTaskFromServer(task: Task, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Error deleting task from server: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    private func updateTasks(with representations: [TaskRepresentation]) throws {
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier) }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var tasksToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            let existingTasks = try context.fetch(fetchRequest)
            
            for task in existingTasks {
                guard let id = task.identifier,
                    let representation = representationsByID[id] else { continue }
                self.update(task: task, with: representation)
                tasksToCreate.removeValue(forKey: id)
            }
            
            for representation in tasksToCreate.values {
                Task(taskRepresentation: representation)
            }
        } catch {
            NSLog("Error fetching tasks with UUIDs: \(identifiersToFetch), with error: \(error)")
        }
        
        try CoreDataStack.shared.mainContext.save()
    }
    
    private func update(task: Task, with representation: TaskRepresentation) {
        task.name = representation.name
        task.notes = representation.notes
        task.priority = representation.priority
        task.complete = representation.complete ?? false
    }
}
