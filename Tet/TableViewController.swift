
//
//  TableViewController.swift
//  Tet
//
//  Created by Steven Johns on 1/18/19.
//  Copyright © 2019 Steven Johns. All rights reserved.
//

import UIKit

typealias reminders = [Reminder]
var tasks: reminders! = []
let defaults = UserDefaults.standard


class TaskCell: UITableViewCell {
    @IBOutlet weak var reminderDetail: UILabel!
    @IBOutlet weak var timeRemainingDetail: UILabel!
    @IBOutlet weak var remainingClause: UILabel!
    
    
    
}



class TableViewController: UITableViewController, UITextFieldDelegate {
    
    var timer = Timer()
    let refreshTime = 60.00
    
    let dateFormatter = DateFormatter()
    
    func taskEnter() {
        guard let x = taskField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        guard x != "" else {
            return
        }
        
        let dateAndTime = Date()
        
        tasks.append(Reminder(description: x, time: dateAndTime))
        print(x, dateAndTime)
        reloadTable()
    }
    
    @IBOutlet weak var enter: UIView!
    @IBOutlet weak var taskField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        taskField.delegate = self
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 300
        
        
        
//        defaults.removeObject(forKey: "taskArray")
        
        
        if let taskData = defaults.data(forKey: "taskArray") {
        
            if let x = try? PropertyListDecoder().decode(reminders.self, from: taskData){
                tasks = x
                print("Acquired list from memory.")
            } else {
                return
            }
        } else { return }
        
        
        
//        tasks.sort(by: {$0.time < $1.time})
        
        
        
    }
    
    @objc func reloadTable(){
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshTime), target: self, selector: #selector(TableViewController.reloadTable), userInfo: nil, repeats: true)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskField.resignFirstResponder()
        taskEnter()
        return true
    }
    
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(TableViewController.dismissKeyboard))
        
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskCell
        
        var reminder = tasks[indexPath.row]
        print(indexPath.row, reminder.comparedTime)
        let allFlagValues = reminder.returnAllFlags()
        print("pf: \(allFlagValues.pauseFlag) rf: \(allFlagValues.repeatFlag) af: \(allFlagValues.archiveFlag)")
        let remainingTime = reminder.comparedTimeInHours
        var remainingTimeString = String(remainingTime)
        
        // make dictionary with the emojis or make a struct to activate them on

        cell.reminderDetail.text = ""
        
        let emojiDictionary = [
            "pause" : "⏸ ",
            "repeat" : "⏰ ",
            "archive" : "☑️ "
        ]
        
        switch allFlagValues {
            case (true, true, true):
                cell.reminderDetail.text! += emojiDictionary["repeat"]! + emojiDictionary["pause"]! + emojiDictionary["archive"]!
            case (true, true, false):
                cell.reminderDetail.text! += emojiDictionary["repeat"]! + emojiDictionary["pause"]!
            case (true, false, true):
                cell.reminderDetail.text! += emojiDictionary["repeat"]! + emojiDictionary["archive"]!
            case (true, false, false):
                cell.reminderDetail.text! += emojiDictionary["repeat"]!
            case (false, true, true):
                cell.reminderDetail.text! += emojiDictionary["pause"]! + emojiDictionary["archive"]!
            case (false, true, false):
                cell.reminderDetail.text! += emojiDictionary["pause"]!
            case (false, false, true):
                cell.reminderDetail.text! += emojiDictionary["archive"]!
            default:
                print("No extra options.")
        }
        
        reminder.repeatTask()
        reminder.pauseTask(false)
        
        if remainingTime <= 0 {
            remainingTimeString = "0"
            tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if remainingTime < 1 {
            cell.reminderDetail.text! += reminder.description
            cell.timeRemainingDetail.text! = "<1h"
            cell.timeRemainingDetail.textColor = .red
            cell.remainingClause.textColor = .red

        } else {
            cell.reminderDetail.text! += reminder.description
            cell.timeRemainingDetail.text! = "\(remainingTimeString)h"
        }
        
//        cell.textLabel?.
        
        tasks[indexPath.row] = reminder
        return cell
    }
   
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        reloadTable()
    }
    */
    
    func contextualPauseAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var reminder = tasks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "Pause") {
            (action, view, completionHandler) in
            
            if reminder.togglePauseFlag(){
                print(reminder.returnAllFlags().pauseFlag)
                reminder.pauseTask(true)
                
                tasks[indexPath.row] = reminder
                print(tasks[indexPath.row].returnAllFlags())
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        
        }
        
        action.image = UIImage.init(named: "PauseIcon")
        action.backgroundColor = .purple
        
        return action
        
        
    }
    
    func contextualRepeatableAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var reminder = tasks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "Repeat") {
            (action, view, completionHandler) in
            
            if reminder.toggleRepeatFlag(){
                print(reminder.returnAllFlags().repeatFlag)
                
                tasks[indexPath.row] = reminder
                print(tasks[indexPath.row].returnAllFlags())
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            
        }
        
        action.image = UIImage.init(named: "RepeatIcon")
        action.backgroundColor = .blue
        
        return action
        
        
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
    
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            
            tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
            
        }
        
        action.image = UIImage.init(named: "DeleteIcon")
        action.backgroundColor = .red
        
        return action
        
        
    }
    
    func contextualArchiveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var reminder = tasks[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "Archive") {
            (action, view, completionHandler) in
            
            if reminder.toggleArchiveFlag(){
                completionHandler(true)
                print(reminder.returnAllFlags().archiveFlag)
                
                tasks[indexPath.row] = reminder
                print(tasks[indexPath.row].returnAllFlags())
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                completionHandler(false)
            }
            
        }
        
        
        action.image = UIImage.init(named: "ArchiveIcon")
        action.backgroundColor = .green
        
        return action
        
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pauseAction = self.contextualPauseAction(forRowAtIndexPath: indexPath)
        let repeatableAction = self.contextualRepeatableAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [pauseAction, repeatableAction])
        return swipeConfig
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let archiveAction = self.contextualArchiveAction(forRowAtIndexPath: indexPath)
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [archiveAction, deleteAction])
        return swipeConfig
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}
