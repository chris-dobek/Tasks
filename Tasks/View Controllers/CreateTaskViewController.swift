//
//  CreateTaskViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CreateTaskViewController: UIViewController {
    
    // MARK: - Properties
    
    var complete = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text,
            !name.isEmpty else { return }
        
        let notes = notesTextView.text
        Task(name: name, notes: notes, complete: complete)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
            return
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        complete.toggle()
        sender.setImage(complete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
}
