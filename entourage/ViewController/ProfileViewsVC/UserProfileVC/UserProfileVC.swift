//
//  UserProfileVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit


class UserProfileVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SubTitleLabel: UILabel!

    @IBOutlet weak var groupStatusAndDistanceView: UIView!
    @IBOutlet weak var groupDistanceLbl: UILabel!

    @IBOutlet weak var groupMemberNumView: UIView!
    @IBOutlet weak var groupMemberNumImage: UIImageView!
    @IBOutlet weak var groupMemberNumLbl: UILabel!
    @IBOutlet weak var groupStatus: UILabel!
    @IBOutlet weak var groupStatusImage: UIImageView!

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var editBtnBtmConst: NSLayoutConstraint!

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var colapsBtn: UIButton!

    @IBOutlet weak var blockUserBtn: UIButton!
    @IBOutlet weak var addUserBtn: UIButton!
    @IBOutlet weak var addUserBtnWith: NSLayoutConstraint!

    //@IBOutlet weak var subTitleBottomConst: NSLayoutConstraint!
    @IBOutlet weak var bioTopConst: NSLayoutConstraint!
    @IBOutlet weak var bioBotmConst: NSLayoutConstraint!
    @IBOutlet weak var editTopConst: NSLayoutConstraint!
    @IBOutlet weak var subTitleTop: NSLayoutConstraint!

    @IBOutlet weak var swipeBtnsView: UIView!
    @IBOutlet weak var iMatch : UIButton!
    @IBOutlet weak var shareBtn : UIButton!

    
    //MARK:- Class Properties
    var callback : OtherUserProfile!
    var numImages = 0//EntourageManager.shared.user.photos.count
    var pageIndex = 0
    var imageName = ""
    var user : User!
    var allGroupMembers : [Int] = [] //EntourageManager.shared.myGroup?.allGroupMember().compactMap({$0.id})
    var group : Group?

    override func setupGUI() {
        super.setupGUI()
        
        self.hideNavBar()
        
        title = "User Profile"

        setUpControllerView()
        setUpBottomView()

        if user.isBlocked ?? false{
            self.blockingUISetUp()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func updateGUI() {
        Utils.currVC = self
    }

    fileprivate func setUpControllerView(){
        
        allGroupMembers = EntourageManager.shared.myGroup?.allGroupMember().compactMap({$0.id}) ?? []
        addUserBtnWith.constant = 60
        swipeBtnsView.isHidden = true
        
        editBtn.layer.borderWidth = 1
        editBtn.isEnabled = true

        if user.id == EntourageManager.shared.user.id{
            blockUserBtn.isHidden = true
            colapsBtn.isHidden = true
            addUserBtn.isHidden = true
            addSwipeGesture()
        }else if allGroupMembers.contains(user.id) == true{
            blockUserBtn.isHidden = true
            colapsBtn.isHidden = true
            editBtnHeight.constant = 0
            editBtn.setTitle("", for: .normal)
        }else{
            swipeBtnsView.isHidden = group == nil ? true : false
            colapsBtn.isHidden = true
            editBtn.isEnabled = false
            editBtn.layer.borderWidth = 0
            editBtn.setTitle("", for: .normal)
        }
        
        if EntourageManager.shared.FriendShips.contains(where: {$0.id == user.id}) == false ,
           user.id != EntourageManager.shared.user.id{//he is not me or not for my friends Lists
            checkUserStatus(userId: user.id )
        }else{
            self.addUserBtn.setImage(UIImage(named: "friends"), for: .normal)
            addUserBtn.isUserInteractionEnabled = false
        }
        
        if EntourageManager.shared.user.instantMatchAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.instantMatchAllow ?? 0 > 0{
            iMatch.isHidden = false
        }else{
            iMatch.isHidden = true
        }

        containerView.layoutIfNeeded()
    }
    
    fileprivate func setUpBottomView(){
        //pageController.customPageControl(dotFillColor: UIColor.white, dotBorderColor: UIColor.white, dotBorderWidth: 2)
        pageController.numberOfPages = numImages

        let name = NSMutableAttributedString(string: "\(user.first_name ?? "")", attributes: [NSAttributedString.Key.foregroundColor : UIColor("#333333") , NSAttributedString.Key.font : UIFont(name: "Avenir-BlackOblique" , size: 32)! ])
        
        let age = NSMutableAttributedString(string: " \(user.age ?? 0)" , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#333333") , NSAttributedString.Key.font : UIFont(name: "Avenir-Light" , size: 24)! ])
        
        let nameWithAge = NSMutableAttributedString(attributedString: name)
        
        nameWithAge.append(age)
        titleLabel.attributedText = nameWithAge

        if user.bio ?? "" == ""{
            bioTopConst.constant = 0
            bioBotmConst.constant = 0
            descriptionLabel.text = ""
        }else{
            bioTopConst.constant = 14
            bioBotmConst.constant = 14
            descriptionLabel.text = "\(user.bio ?? "")"
        }
    
                
        if user.id != EntourageManager.shared.user.id{
            SubTitleLabel.text = ""
            shareBtn.isHidden = true
        }else{
            shareBtn.isHidden = false
            SubTitleLabel.addAttachmentImageWithShareBTn(imageName: "share"  , text: " \(user.user_name ?? "")", textColor: UIColor("#00d8ff") )
            SubTitleLabel.textAlignment = .left
        }

        
        
        if group != nil{
            
            SubTitleLabel.text = ""
            shareBtn.isHidden = true

            //subTitleBottomConst.constant = 86
            subTitleTop.constant = 0

            groupMemberNumView.isHidden = false
            groupStatusAndDistanceView.isHidden = false

            if let url = URL(string:group?.groupStatus.icon ?? ""){
                groupStatusImage.kf.indicatorType = .activity
                groupStatusImage.kf.setImage(with: url)
            }
            groupStatus.text = group?.groupStatus.name ?? ""
            groupMemberNumLbl.text = "\(group?.users.count ?? 0) people"
            groupDistanceLbl.text = "\(group?.distance ?? "0 Miles")"
            groupMemberNumImage.image = UIImage(named: "memberNum\(group!.users.count)")
            
        }else{
            //subTitleBottomConst.constant = 14
            groupMemberNumView.isHidden = true
            groupStatusAndDistanceView.isHidden = true
            subTitleTop.constant = 10
        }

        //containerView.backgroundColor = .red
        containerView.setGradientBackground(colorOne: UIColor("#FFFFFF"), colorTwo: UIColor("#f6f7fb"))
        collectionView.reloadData()
        
    }
    
   fileprivate func addSwipeGesture(){
        
        editBtnHeight.constant = 52
        editBtn.setTitle("Edit Profile", for: .normal)

    }
    
    fileprivate func blockUser(){
        self.startAnimation()
        WebServicesManager.shared.blockFriend (frendId: user.id) { (reponse, error) in
            self.stopAnimation()
            if error == nil{
                if EntourageManager.shared.myGroup?.users.contains(where: {$0.id == self.user.id }) ?? false == true{
                    Utils.updateMyGroup = true
                }else{
                    Utils.mainVC?.getOtherGroups(pageIndex: Utils.mainVC?.pageIndex ?? 1)
                }
                    self.navigationController?.popToRootViewController(animated: false)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }

    fileprivate func unBlockUser(){
        self.startAnimation()
        WebServicesManager.shared.unblockedTheUsers(block_users: [user.id].description) { (response, error) in
            if error == nil{
                self.stopAnimation()
                self.user.isBlocked = false
                self.setupGUI()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    fileprivate func checkUserStatus(userId:Int){
        
        self.startAnimation()
        WebServicesManager.shared.checkUserFriendStatus(frendId: userId) { (reponse, error) in
            self.stopAnimation()

            if error == nil{
                
                
                if let status = reponse as? String{
                    
                    self.addUserBtnWith.constant = status == "requested" ? 60 : 60

                    if status == "request"{
                    
                        self.addUserBtn.isUserInteractionEnabled = true
                        self.addUserBtn.setImage(UIImage(named: "noRelation"), for: .normal)
                        self.editTopConst.constant = 41

                    }else{
                        
                        //let newStatus = status == "match" ? "Friends" : status
                        self.addUserBtn.isUserInteractionEnabled = false
                        self.editTopConst.constant = 41

                        if status == "block" || status == "blocked"{
                            self.swipeBtnsView.isHidden = true //when status is Blocked then Card Swipe Btns is Hide
                            self.addUserBtn.setImage(UIImage(named: "Blocked"), for: .normal)
                            self.editTopConst.constant = 0
                        }else if status == "requested"{
                            self.addUserBtn.setImage(UIImage(named: "requested"), for: .normal)
                        }else{
                            self.addUserBtn.setImage(UIImage(named: "friends"), for: .normal)
                        }
                        
                    }
                }
                

                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
 
    fileprivate func blockingUISetUp(){
        
      self.loadBlockAlertVC(user: user) { (comfirmBtnPress) in
            
            if comfirmBtnPress{
                
                if self.user.isBlocked ?? false{
                    self.unBlockUser()
                }else{
                    self.blockUser()
                }
            }
        }
        
    }
    
}


// MARK: - Actions
extension UserProfileVC{

    @IBAction func pressShareBtn(_ sender: UIButton) {
        let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
        self.present(ac, animated: true)
    }

    @IBAction func pressLikeBtn(_ sender: UIButton) {

        callback("Like")
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func pressUnLikeBtn(_ sender: UIButton) {
        callback("unLike")
        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func pressiMatchBtn(_ sender: UIButton) {
        callback("iMatch")
        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func pressAddFriendBtn(_ sender: UIButton) {
        
        self.startAnimation()
        WebServicesManager.shared.sendRequest(frendId: user.id ) { (reponse, error) in
            self.stopAnimation()
            if error == nil{
                
                if reponse != nil{
                    
                    self.checkUserStatus(userId: self.user.id)
                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }

    }

    @IBAction func pressBlockProfileBtn(_ sender: Any) {
        self.blockingUISetUp()
    }

    @IBAction func pressEditBtn(_ sender: Any) {
        self.loadEditProfileVC {
            self.user = EntourageManager.shared.user
            self.numImages = EntourageManager.shared.photos.count
            self.setUpBottomView()
        }
    }

    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                editBtnHeight.constant = 0
                //editBtnBtmConst.constant = 0
                editBtn.setTitle("", for: .normal)
                UIView.animate(withDuration: 0.2, animations: {
                    self.containerView.layoutIfNeeded()
                }, completion: nil)

            case UISwipeGestureRecognizer.Direction.up:
                editBtnHeight.constant = 52
                //editBtnBtmConst.constant = 38
                editBtn.setTitle("Edit Profile", for: .normal)
                UIView.animate(withDuration: 0.2, animations: {
                    self.containerView.layoutIfNeeded()
                }, completion: nil)
            default:
                break
            }
        }
    }
}


//MARK: - UICollectionDataSource
extension UserProfileVC : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileVCCell", for: indexPath) as! UserProfileVCCell
        
        if let photo = user.photos.first(where: {$0.order == indexPath.row}){
            
            if let url = URL(string: photo.original ?? "") {
                cell.imageView.kf.indicatorType = .activity
                //cell.imageView.kf.setImage(with: url)
                setupThumnail(url: url, IV: cell.imageView)
            }
        }

        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        pageIndex = Int(targetContentOffset.pointee.x / view.frame.width)
        pageController.currentPage = pageIndex
        
        //pageController.customPageControl(dotFillColor: UIColor.white, dotBorderColor: UIColor.white, dotBorderWidth: 2)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height : CGFloat = collectionView.frame.height + (statusBar ?? 0.0)
        
        return CGSize(width: self.view.frame.width , height: height )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
 
}
