//
//  SelectGroupActivityVCCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class SelectGroupActivityVCCell: UITableViewCell {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
   // @IBOutlet weak var eventDesLabel: UILabel!

    @IBOutlet weak var checkImage: UIImageView!
    
    var select : Bool = false

    func cellSetUp(event:GroupStatuses,listType:String){
        
        if let url = URL(string: event.icon ?? ""){
            eventImageView.kf.setImage(with: url)
        }

        let selecetdGroupStatusImage = UIImage(named: "Group\(listType)Status")
        checkImage.image = select == true ? selecetdGroupStatusImage  : UIImage(named: "selection_circle")
        
        eventTitleLabel.text = event.name ?? ""
        
        if select {
            eventTitleLabel.textColor = listType == "Other" ? Colors.themeColor.value : UIColor("#6c62ff")
        } else {
            eventTitleLabel.textColor = UIColor.black
        }

    }
}
