//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var task: Task?
    var wasEdited = false
    
    // MARK: - Outlets

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        
        updateViews()
    }
    
    private func updateViews() {
        nameTextField.text = task?.name
        nameTextField.isUserInteractionEnabled = isEditing
        
        notesTextView.text = task?.notes
        notesTextView.isUserInteractionEnabled = isEditing
        
        completeButton.setImage((task?.complete ?? false) ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
        let priority: TaskPriority
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        
        priorityControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: priority) ?? 1
        priorityControl.isUserInteractionEnabled = isEditing
    }
}
