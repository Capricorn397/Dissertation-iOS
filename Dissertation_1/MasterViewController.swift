//
//  MasterViewController.swift
//  Dissertation_1
//
//  Created by Christopher Carr on 19/02/2017.
//  Copyright © 2017 Christopher Carr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var wait = false
    var quest_dict: [[String: Any]] = [["fail":"fail"]]
    var defaults = UserDefaults.standard
    var wait2 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:
        #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        if defaults.integer(forKey: "firstRun") == 1 {
            wait2 = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQuestions() -> [[String: Any]] {
        var lock = true
        let module:String = self.defaults.string(forKey: "module")!
        let mod_header = [ "mod": module]
        Alamofire.request("http://217.182.64.177:8000/question",
            method: .get,
            headers: mod_header
            )
            .response { response in
                let data = response.data
                self.quest_dict = try! JSONSerialization.jsonObject(with: data!) as! [[String : Any]]
                lock = false
        }
        while (lock == true){hold()}
        wait = false
        return quest_dict
    }
    
    var valueToPassID = String.self
    var valueToPassQ = String.self

    @objc func insertNewObject(_ sender: Any) {
        if defaults.integer(forKey: "firstRun") == 1 {
            checkMod()
        }
        while wait2 == true {
            hold()
        }
        objects.removeAll()
        self.tableView.reloadData()
        let data = self.getQuestions();
        while (wait == true){hold()}
        let max = data.count - 1
        if max > -1 {
            for index in 0...max {
                objects.insert(data[index]["question"]!, at: 0)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
            wait = true
        }
    }

    func hold() {
        RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 1) as Date)
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row];
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object as? String
                let point = quest_dict.endIndex - 1
                controller.qID = quest_dict[point - indexPath.row]["id"] as! NSString?
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func checkMod() {
        if defaults.integer(forKey: "firstRun") == 1 {
            let alert = UIAlertController(title: "Please Enter Module Code", message: "Please use lower case letters", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0].text! as String
                let nsTextField:NSString = NSString(string:(textField))
                self.defaults.set(nsTextField, forKey: "module")
                self.wait2 = false
                self.defaults.set(2, forKey: "firstRun")
            }))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    @IBOutlet weak var mainName: UINavigationItem!

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = (object as AnyObject).description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

