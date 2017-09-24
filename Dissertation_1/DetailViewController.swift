//
//  DetailViewController.swift
//  Dissertation_1
//
//  Created by Christopher Carr on 19/02/2017.
//  Copyright © 2017 Christopher Carr. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerBox: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sentLabel: UILabel!
    var qID:NSString?

    func configureView() {
        // Update the user interface for the detail item.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = detailItem
        sentLabel.isHidden = true
        self.configureView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func doneEnd(_ sender: Any) {
        view.endEditing(true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let post_headers = ["qid": qID as! String,
                            "uid": "iOSTestApp"]
        if (answerBox.text == nil) {
            answerBox.placeholder = "Enter Answer First"
        } else {
            let parameters = ["answer": answerBox.text!]
            Alamofire.request("http://217.182.64.177:8000/answerin", method: .post, parameters: parameters, encoding: JSONEncoding.default,  headers: post_headers)
                .response { response in
                    let data = response.data
                    if data != nil {
                        self.sentLabel.isHidden = false
                    }
            }

        }
    }

}

