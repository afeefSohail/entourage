//
//  PremiumVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

class PremiumVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var featuredTableView: UITableView!

    //MARK: - Class Proprties
    var titleArray = ["Unlimited Likes","See who’s liked your Group","+5 InstaMatches","Additional Filters"]
    var descArray = ["Send as many likes as you’d like, no more waiting.","Instantly match with groups who have already liked.",
                    "Get 5 more InstaMatches per month.","Filter distance, group status, and grou members."]
    var selectedFeatures : [Int] = []
    override func setupGUI() {
        super.setupGUI()
    
        self.featuredTableView.estimatedRowHeight = 52
        self.featuredTableView.rowHeight = UITableView.automaticDimension

    }
    
    
    //MARK: - Actions
    @IBAction func pressContinueBtn(_ sender: Any) {
        
    }

}


// MARK: - UITableViewDataSource
extension PremiumVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumVCCell", for: indexPath) as! PremiumVCCell
    

        cell.titleLabel.text = titleArray[indexPath.item]
        cell.descLabel.text = descArray[indexPath.item]
        

        //cell.delegate = self
    return cell
    }
    
    
}

// MARK: - SwipeTableViewCellDelegate
extension PremiumVC : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //set Orientation Direction
        guard orientation == .left else { return nil }
        
        //deletionAction
        let deleteAction = SwipeAction(style: .default, title: "") { action, indexPath in
            self.selectedFeatures.append(indexPath.item)
        }
        
        // customize  Deletion the action appearance
        deleteAction.image = UIImage(named: "righthand")!
        deleteAction.backgroundColor = UIColor.clear
        
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
