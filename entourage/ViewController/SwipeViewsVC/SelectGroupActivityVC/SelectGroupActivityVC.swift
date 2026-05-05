//
//  SelectGroupActivityVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FittedSheets

class SelectGroupActivityVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var PressDoneBtn: UIButton!
    @IBOutlet weak var PressGoThereBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var statusImage : UIImageView!
    
    @IBOutlet weak var customeStatusTabView: UIView!
    @IBOutlet weak var tab1View: UIView!
    @IBOutlet weak var tab2View: UIView!
    @IBOutlet weak var tab3View: UIView!
    
    @IBOutlet weak var tab1Lbl: UILabel!
    @IBOutlet weak var tab2Lbl: UILabel!
    @IBOutlet weak var tab3Lbl: UILabel!
        
    @IBOutlet weak var doneBtnOuterView: UIView!
    @IBOutlet weak var doneBtnOuterViewHeight: NSLayoutConstraint!
    
    //MARK:- Class Properties
    
    let user = EntourageManager.shared.user
    var callback : createGroup!
    var friendIds : [Int] = []
    var updateStatus = false
    var statusList : [GroupStatuses] = []
    var otherStatusList : [GroupStatuses] = []
    var placesStatusList : [GroupStatuses] = []
    var groupId = 0
    var listType = "Other"
    var selectedStatusListType = "Other"
    var selectedStatusIndex = -1


    
    //MARK:- Constructor
    class func loadSelectGroupActivityVC(firendIds:[Int],update:Bool,listType:String,callback :@escaping createGroup )->SelectGroupActivityVC {
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  selectGroupActivityVC = storyboard.instantiateViewController(withIdentifier: "SelectGroupActivityVC") as! SelectGroupActivityVC
        
        selectGroupActivityVC.callback = callback
        selectGroupActivityVC.friendIds = firendIds
        selectGroupActivityVC.updateStatus = update
        selectGroupActivityVC.listType = listType

        return selectGroupActivityVC
    }

    override func setupGUI() {
        super.setupGUI()
        
        self.title = "groupActivity"
                
        // just to make cell height auto grow
        tableView.estimatedRowHeight = 56.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        PressDoneBtn.isEnabled = false
        //customeStatusTabView.isHidden = !updateStatus
        
        if updateStatus == false{ // new Group Status
            setGroupStatus(iconUrl: "")
        }else{// if status Updating
            
            groupId = EntourageManager.shared.myGroup!.groupStatus.id ?? 0
            if EntourageManager.shared.myGroup!.groupStatus.statusType !=  "custom"{
                selectedStatusListType = EntourageManager.shared.myGroup!.groupStatus.statusType == "place" ? "Place" : "Other"
                setGroupStatus(iconUrl: EntourageManager.shared.myGroup!.groupStatus.icon ?? "")
            }else{
                //listType = "Other"
                selectedStatusListType = "custom"
                setGroupStatus(iconUrl: EntourageManager.shared.myGroup!.groupStatus.icon ?? "")
            }
        }
        
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action:#selector(tapTheOuterView))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        containerView.addGestureRecognizer(swipeDown)
        
        sheetViewController?.handleScrollView(self.tableView)
        setTabView(activeTab: self.listType == "Other" ? 1 : 3)

        startAnimation()
        getGroupStatusList(lisType: "default") {
            self.getGroupStatusList(lisType: "place") {
                self.setTabView(activeTab: self.listType == "Other" ? 1 : 3)
                self.stopAnimation()
            }
        }

        PressGoThereBtn.horizentalGradient(colorOne: UIColor("#6c62ff"), colorTwo: UIColor("#a59bff"),cornerRdaius:10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.animation()
    }
    
    fileprivate func setGroupStatus(iconUrl:String){
        self.changeContinueBtnColor()
        
        guard let url = URL(string: iconUrl) else{
            return
        }
        statusImage.kf.setImage(with: url)
    }
    
    fileprivate func getGroupStatusList(lisType:String,compplete:@escaping ()->Void){
        WebServicesManager.shared.getGroupStatus(lisType: lisType){ (response, error) in
            if error == nil{
                
                if lisType == "default" {

                    if let index = EntourageManager.shared.groupStatuses.firstIndex(where: {$0.name == "chat"}) {
                        EntourageManager.shared.groupStatuses.remove(at: index)
                    }
                    self.otherStatusList = EntourageManager.shared.groupStatuses
                    
                    if let index = EntourageManager.shared.groupStatuses.firstIndex(where: {$0.id == self.groupId}),self.selectedStatusListType == "Other"{
                        self.selectedStatusIndex = index
                    }

                }else{
                    self.placesStatusList = EntourageManager.shared.groupStatuses
                
                    if let index = EntourageManager.shared.groupStatuses.firstIndex(where: {$0.id == self.groupId}),self.selectedStatusListType == "Place"{
                        self.selectedStatusIndex = index
                    }

                }
                
                compplete()
            }else{
                compplete()
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
        
    fileprivate func createGroup(){
        self.startAnimation()
        WebServicesManager.shared.createGroup(groupStatusId: self.groupId, friendsIds: self.friendIds.description) { (response, error) in
            self.stopAnimation()
            if error == nil{
                Utils.updateMyGroup = true
                self.closeAnimation()
            }else{
                self.showAlert(title: "Error", message:error!)
            }
        }
        
    }
    
    fileprivate func updateEventStatus(){
        let myGroup = EntourageManager.shared.myGroup!
        self.startAnimation()
        WebServicesManager.shared.updateGroupStatus(groupId: myGroup.id  , groupStatusId: self.groupId) { (response, error) in
            self.stopAnimation()
            if error == nil{
                self.closeAnimation()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    fileprivate func setTabView(activeTab:Int){
        
        setUpSelective(tab: activeTab)
        if activeTab == 1{
            tab1ReloadView(listType: "Other")
        }else if activeTab == 2{
            tab2ReloadView(listType: "")
        }else{
            tab3ReloadView(listType: "Place")
        }
    }
    
    fileprivate func tab1ReloadView(listType:String){
        //TrendingStatus reload
        
        PressGoThereBtn.isHidden = true
        self.listType = listType
        self.outerView.backgroundColor = UIColor("#676872").withAlphaComponent(0.65)
        self.statusList = otherStatusList
        self.tableView.reloadData()
    }
    
    
    
    fileprivate func tab2ReloadView(listType:String){
        
        if updateStatus == true{//if user tab for Update Group Status
            
            self.dismiss(animated: false) {
                self.callback(false)
            }
            
        }else{ // if user tab first Time Group Created
            //TODO:-  Work From Server Side.
            self.dismiss(animated: false) {
                self.callback(false)
            }
        }
        
    }
    
    fileprivate func tab3ReloadView(listType:String){
        //placeReload
        PressGoThereBtn.isHidden = false
        self.listType = listType
        self.outerView.backgroundColor = UIColor("#676872").withAlphaComponent(0.65)
        self.statusList = placesStatusList
        self.tableView.reloadData()
        
    }
    
    
    fileprivate func closeAnimation(){
        self.callback(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate func changeContinueBtnColor(){
        self.PressDoneBtn.backgroundColor = self.PressDoneBtn.isEnabled == false ? UIColor("#D2D2D2")  : Colors.themeColor.value
        
    }
    
}

// MARK: - Actions
extension SelectGroupActivityVC{
    
    
    @IBAction func pressTrendingTab(sender:UIButton){
        setTabView(activeTab: 1)
    }
    
    @IBAction func pressCustomStatusTab(sender:UIButton){
        setTabView(activeTab: 2)
    }
    
    @IBAction func pressPlaceStatusTab(sender:UIButton){
        setTabView(activeTab: 3)
    }
    
    @objc func tapTheOuterView(){
        //self.containerViewHeight.constant = 0
        self.PressDoneBtn.isHidden = true
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
        }) { (bool) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @IBAction func PressDoneBtn(_ sender: Any) {
        notificationFeedBackBtn(.success)
        if updateStatus == true{
            updateEventStatus()
        }else{
            createGroup()
        }
        
    }
    
    
    
}

//MARK: - UITableViewDataSource
extension SelectGroupActivityVC : UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGroupActivityVCCell", for: indexPath) as! SelectGroupActivityVCCell
        
        cell.select = false
        
        if selectedStatusIndex == indexPath.item , selectedStatusListType == listType {
            
            cell.select = true
            PressGoThereBtn.isEnabled = listType == "Place" ? true : false
            PressDoneBtn.isEnabled = listType == "Other" ? true : false
            groupId = statusList[indexPath.item].id ?? 0
            setGroupStatus(iconUrl: statusList[indexPath.item].icon ?? "")
        }
        
        cell.cellSetUp(event: statusList[indexPath.item], listType: listType)
        
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate
extension SelectGroupActivityVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedStatusIndex = indexPath.item
        selectedStatusListType = listType
        self.tableView.reloadData()
    }
    
}

// MARK: - UITextFieldDelegate
extension SelectGroupActivityVC : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
