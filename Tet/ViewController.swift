//
//  ViewController.swift
//  Tet
//
//  Created by Steven Johns on 2/4/19.
//  Copyright © 2019 Steven Johns. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,  UITableViewDelegate, UITableViewDataSource {
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshTime), target: self, selector: #selector(TableViewController.reloadTable), userInfo: nil, repeats: true)
        
    }
    
    @objc func reloadTable(){
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        return UITableViewCell()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
