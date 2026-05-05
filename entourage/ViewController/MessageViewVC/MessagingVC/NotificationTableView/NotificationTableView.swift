//
//  NotificationTableView.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

class NotificationTableView: NSObject , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.item == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestAcceptedCell", for: indexPath) as! RequestAcceptedCell
            
            return cell
        }else if indexPath.item == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddRequestCell", for: indexPath) as! AddRequestCell

            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherNotifcationCell", for: indexPath) as! OtherNotifcationCell
            
            if indexPath.item == 3{
                
                cell.mainImage.image = UIImage(named: "ContactsAddtions")
                cell.messageTitle.text = "Stacy Joined and Added You from Contacts"
                cell.descriptionLabel.text = "You can now see their flares on the map"
                cell.timeLabel.text = "01/20/19"

            }else if indexPath.item == 4{

                cell.mainImage.image = UIImage(named: "EpiredGroup")
                cell.messageTitle.text = "Group Expired"
                cell.descriptionLabel.text = "Check out the Event until 2:00 pm"
                cell.timeLabel.text = "01/20/19"

                cell.delegate = self
            }
            
            return cell
        }
        
    }
    

}


// MARK: - SwipeTableViewCellDelegate
extension NotificationTableView : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //set Orientation Direction
        guard orientation == .right else { return nil }
        
        //deletionAction
        let deleteAction = SwipeAction(style: .default, title: "Cancel") { action, indexPath in
            
        }
        
        // customize  Deletion the action appearance
        deleteAction.image = UIImage(named: "delet")!
        deleteAction.textColor = UIColor("#666666")
        
        // customize  ScoreCard the action appearance
        deleteAction.backgroundColor = UIColor.white
        
        return [deleteAction]

    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        return options
    }

    
}
