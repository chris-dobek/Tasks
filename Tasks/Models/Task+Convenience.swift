//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}

extension Task {
    
    var taskRepresentation: TaskRepresentation? {
        guard let id = identifier,
            let name = name,
            let priority = priority else {
                return nil
        }
        
        return TaskRepresentation(identifier: id.uuidString,
                                  name: name,
                                  notes: notes,
                                  priority: priority,
                                  complete: complete)
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                     name: String,
                     notes: String? = nil,
                     complete: Bool = false,
                     priority: TaskPriority = .normal,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        // Standard init, does usual init stuff
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.notes = notes
        self.complete = complete
        self.priority = priority.rawValue
    }
}
