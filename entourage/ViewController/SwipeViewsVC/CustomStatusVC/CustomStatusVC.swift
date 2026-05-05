//
//  CustomStatusVC.swift
//  entourage
//
//  Created by afeef sohail on 1/5/20.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit
import FittedSheets

class CustomStatusVC: BaseVC {
    
    //MARK:-IBOutLets
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var statusNameTF : UITextField!
    @IBOutlet weak var statusImage : UIImageView!
    @IBOutlet weak var bottomLine : UIView!
    @IBOutlet weak var PressContinueBtn: UIButton!
    
    @IBOutlet weak var tab1View: UIView!
    @IBOutlet weak var tab2View: UIView!
    
    @IBOutlet weak var tab1Lbl: UILabel!
    @IBOutlet weak var tab2Lbl: UILabel!
    
    //MARK: - General Properties
    let ranges = [
        0x1F486...0x1F9D7
    ]
    
    var images : [UIImage] = []
    var callback : createCustomeStatus!
    var selectedIndex = [-1,-1]
    var recentGroup : [GroupStatuses] = []
    var friendIds : [Int] = []
    
    override func setupGUI() {
                
        changeContinueBtnColor()
        
        setMemberImages()
        
        images =  getValidEmoji(range: ranges[0]).compactMap { String($0).image() }
        
        collectionView.allowsMultipleSelection = false
        collectionView.keyboardDismissMode = .onDrag
        
        getRecentStatus()
        
        setTabView(activeTab: 2)
    }
    
    override func updateGUI() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
                self.statusNameTF.becomeFirstResponder()
        }

    }
    
    fileprivate func setMemberImages(){
        var images : [String] = []
        
        EntourageManager.shared.myGroup?.users.forEach({images.append($0.getPrimaryImageThumb())})
        
        if images.count > 0{
            images.removeLast()
        }
        
        for (index,value) in images.enumerated(){
            
            let image = getImageViewWith(tag: index+5 , view: self.view)
            
            if let url = URL(string:value){
                image.kf.indicatorType = .activity
                //image.kf.setImage(with: url)
                setupThumnail(url: url, IV: image)
            }
        }
        
    }
    
    
    
    private func changeContinueBtnColor(){
        self.PressContinueBtn.backgroundColor = validationSuccessful() == false ? UIColor("#D2D2D2") : Colors.themeColor.value
        self.PressContinueBtn.isHidden = tfValidationSuccessful() == false ? true : false
    }
    
    
    private func setTabView(activeTab:Int){
        setUpSelective(tab: activeTab)
        if activeTab == 1{
//            tab1Lbl.textColor = UIColor.black
//            tab1Lbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
//            tab2Lbl.textColor = UIColor.lightGray
//            tab2Lbl.font = UIFont(name: "Avenir-Book", size: 17)
//            tab1View.isHidden = false
//            tab2View.isHidden = true
            trendingTabPress()
        }else if activeTab == 2{
//            tab2Lbl.textColor = UIColor.black
//            tab2Lbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
//            tab1Lbl.textColor = UIColor.lightGray
//            tab1Lbl.font = UIFont(name: "Avenir-Book", size: 17)
//            tab2View.isHidden = false
//            tab1View.isHidden = true
        }else{
            placeTabPress()
        }
    }
    
    private func trendingTabPress(){
        
        self.dismiss(animated: true) {
            self.callback(false,"Other")
        }
    }
    

    private func placeTabPress(){
        
        self.dismiss(animated: true) {
            self.callback(false,"Place")
        }
    }

    fileprivate func createGroup(groupStatusId:Int){
        if friendIds.isEmpty {
            return
        }
        
        startAnimation()
        WebServicesManager.shared.createGroup(groupStatusId: groupStatusId, friendsIds: self.friendIds.description) { (response, error) in
            self.stopAnimation()
            if error == nil{
                Utils.updateMyGroup = true
                self.callback(true,"Custom")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showAlert(title: "Error", message:error!)
            }
        }
        
    }
 
    fileprivate func updateGroupStatus(groupStatusId:Int){
        let myGroup = EntourageManager.shared.myGroup!
        startAnimation()
        WebServicesManager.shared.updateGroupStatus(groupId: myGroup.id  , groupStatusId: groupStatusId) { (response, error) in
            self.stopAnimation()
            if error == nil{
                self.dismiss(animated: true, completion: nil)
                self.callback(true,"Custom")
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }

}

//MARK: - Constructor
extension CustomStatusVC {
    
    class func loadCustomStatusVC(friendsIds:[Int]? = [], callback :@escaping createCustomeStatus )->CustomStatusVC {
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  customStatusVC = storyboard.instantiateViewController(withIdentifier: "CustomStatusVC") as! CustomStatusVC
        
        customStatusVC.callback = callback
        customStatusVC.friendIds = friendsIds ?? []
        
        return customStatusVC
    }
    
}

//MARK: - ApiHook
extension CustomStatusVC{
    
    private func getRecentStatus(){
         self.startAnimation()
         WebServicesManager.shared.getRecentCoustomeGroupStatus { (response, error) in
             self.stopAnimation()
             if error == nil{
                 
                 guard let list = response as? [GroupStatuses] else{
                     return
                 }
                 
                 self.recentGroup = list
                 self.collectionView.reloadData()
                 
             }else{
                 self.collectionView.reloadData()
                 self.showAlert(title: "Error", message: error!)
             }
         }
         
     }
    
    
    private func createCustomStatus(){
        
        guard let image = self.statusImage.image else{
            self.showAlert(title: "Alert", message: "Select the status image.")
            return
        }
        
        self.startAnimation()
        WebServicesManager.shared.createCustomStatus(statusName: statusNameTF.text ?? "", image: image.pngData() ?? Data()) { (response, error) in
            self.stopAnimation()
            
            if error == nil{
                
                guard let groupCustomStatus = response as? GroupStatuses else {
                    return
                }
                
                if EntourageManager.shared.myGroup == nil{//Set Group Status of New Group First Time
                    self.createGroup(groupStatusId: groupCustomStatus.id ?? 0)
                }else if EntourageManager.shared.myGroup?.status == "inactive"{//Set Group Status of Old Group from InActive to Active State
                    self.updateGroupStatus(groupStatusId: groupCustomStatus.id ?? 0)
                }else{//update Old Group Status
                    EntourageManager.shared.myGroup?.groupStatus = groupCustomStatus
                    self.dismiss(animated: true, completion: nil)
                    self.callback(true,"Custom")
                }

            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }


}
//MARK: - Action
extension CustomStatusVC{
    
    @IBAction func pressTrendingTab(sender:UIButton){
        setTabView(activeTab: 1)
    }
    
    @IBAction func pressCustomStatusTab(sender:UIButton){
        setTabView(activeTab: 2)
    }

    @IBAction func pressPlaceStatusTab(sender:UIButton){
        setTabView(activeTab: 3)
    }

    @IBAction func pressSetStatusBtn(_ sender:Any){
        
        if validationSuccessful() {
            notificationFeedBackBtn(.success)
            self.createCustomStatus()
        }
        
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        changeContinueBtnColor()
    }
    
}

//MARK: - Validation
extension CustomStatusVC  {
    
    func tfValidationSuccessful() -> Bool {
        
        if statusNameTF.text?.count ?? 0 > 2 , statusNameTF.text?.count ?? 0 <= 25 {
            
            //if validationSucsessfull
            return true
            
        }else{
            
            return false
        }
        
    }

        func validationSuccessful() -> Bool {
            
            if statusNameTF.text?.count ?? 0 > 2 , statusNameTF.text?.count ?? 0 <= 25 {
                guard let _ = self.statusImage.image else{
                    return false
                }
                
                //if validationSucsessfull
                return true
                
            }else{
                
                return false
            }
            
        }

}


//MARK: -
extension CustomStatusVC : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var section = 0
        if recentGroup.count > 0{
            section += 1
        }
        
        section += 1
        
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader{
            if indexPath.section == 0 , recentGroup.count > 0{
                sectionHeader.sectionHeaderlabel.text = "Recent Emojis"
            }else{
                sectionHeader.sectionHeaderlabel.text = "More Emojis"
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 , recentGroup.count > 0{
            return recentGroup.count
        }else{
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomStatusVCCell", for: indexPath) as! CustomStatusVCCell
        
        cell.emojiImage.contentMode = .scaleAspectFit
        
        if indexPath.section == 0 , recentGroup.count > 0{
            cell.recentStatus(status: recentGroup[indexPath.item])
        }else {
            cell.emojiImage.image = self.images[indexPath.item]
        }
        
        if selectedIndex[1] == indexPath.item, selectedIndex[0] == indexPath.section {
            cell.backView.backgroundColor = UIColor("#6C62FF").withAlphaComponent(0.5)
            statusImage.image = cell.emojiImage.image ?? UIImage()
            changeContinueBtnColor()
            
        }else{
            cell.backView.backgroundColor = .white
        }
        
        return cell
    }
    
    
}

//MARK: -
extension CustomStatusVC : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 , recentGroup.count > 0{
            return UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0)
        }else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex[0] = indexPath.section
        selectedIndex[1] = indexPath.item
        collectionView.reloadData()//reloadItems(at: [indexPath])
    }
    
}



//MARK: - UITextFieldDelegte
extension CustomStatusVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        changeContinueBtnColor()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 25{
            self.bottomLine.backgroundColor = UIColor("#F02424")
            textField.shake()
        }else{
            self.bottomLine.backgroundColor = UIColor("#6C62FF")
        }
        
        return updatedText.count <= 26
    }
}
