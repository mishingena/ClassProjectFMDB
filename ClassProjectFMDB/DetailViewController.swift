//
//  DetailViewController.swift
//  ClassProjectFMDB
//
//  Created by Gena on 25.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIkit

class DetailViewController: UIViewController {
    var fruit: FruitModel?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.setUpTextView()
        self.titleTextField.text = fruit!.name
        self.detailsTextView.text = fruit!.details
        self.imageView.sd_setImageWithURL(fruit!.imageURL)

    }
    
    func setUpTextView() {
        detailsTextView.layer.cornerRadius = 10.0
        detailsTextView.layer.masksToBounds = true
        detailsTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        detailsTextView.layer.borderWidth = 1.5
    }
    
    override func viewWillDisappear(animated: Bool) {
        fruit!.name = titleTextField.text
        fruit!.details = detailsTextView.text
        DatabaseManager.sharedInstance.saveFruit(fruit)
    }
    
}
