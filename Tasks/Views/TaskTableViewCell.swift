//
//  TaskTableViewCell.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TaskCell"
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!

    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    // TODO: Add action for toggling complete button
    
    private func updateViews() {
        guard let task = task else { return }
        
        taskNameLabel.text = task.name
        completedButton.setImage(task.complete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
}
