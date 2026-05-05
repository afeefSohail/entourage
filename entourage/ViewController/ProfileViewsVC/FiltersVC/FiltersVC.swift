//
//  FiltersVC.swift
//  entourage
//
//  Created by afeef sohail on 11/28/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class FiltersVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!

    
    //MARK: - Class Properties
    var setting = EntourageManager.shared.setting
    var filters = ["Females" , "Males" , "Everyone"]
    
    //MARK: - Constructor
    class func loadFiltersVC()->FiltersVC{
        let filtersVC = UIStoryboard(name: "ProfileViews", bundle: nil).instantiateViewController(identifier: "FiltersVC") as! FiltersVC
        
        return filtersVC
    }
    
    override func setupGUI() {
        super.setupGUI()
        
        title = "Show Me"
    }
    
    override func updateGUI() {
        Utils.currVC = self
        
        self.navigationController?.navigationBar.setSettingNavBarShadow()

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    
    }
    
}

//MARK: - UITableViewDataSource
extension FiltersVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilttersVCCell", for: indexPath) as! OptionCell
        
        if indexPath.item == 0{
            cell.checkMark.isHidden = setting?.female_only ?? false == true ? false : true
        }else if indexPath.item == 1{
            cell.checkMark.isHidden =  setting?.male_only ?? false == true ? false : true
        }else {
            cell.checkMark.isHidden =  setting?.everyone ?? false == true ? false : true
        }
        
        cell.filterName.text = filters[indexPath.item]
        cell.btmBreakView.isHidden = filters.count - 1 == indexPath.item ? false : true

        return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension FiltersVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            setting?.female_only = true
            setting?.male_only = false
            setting?.everyone = false
        }else if indexPath.item == 1{
            setting?.female_only = false
            setting?.male_only = true
            setting?.everyone = false
        }else {
            setting?.female_only = false
            setting?.male_only = false
            setting?.everyone = true
        }

        Utils.updateMyGroup = true
        EntourageManager.shared.setting = setting

        tableView.reloadData()
    }
}
