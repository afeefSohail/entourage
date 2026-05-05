//
//  ProfilePictureVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class ProfilePictureVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueBtn: UIButton!
    
    //MARK:- Class Properties
    var imagePicker = UIImagePickerController()
    //bttn_uploadPhoto
    var selectImage : [UIImage] = [UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")!,
                                   UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")!,
                                   UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")! ]
    
    var userPhotos = EntourageManager.shared.photos
    var selectedCellIndex = 0
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    override func setupGUI() {
        super.setupGUI()
        
        //set the BackButton
        self.useBackButton(image: UIImage(named: "chevron-back")!)
        
        self.addNavBarShadow()
        self.title = "Add Profile Picture"
        
        //set the imagePickerDelegate
        imagePicker.delegate = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)

        self.setUPContinueBtn()
    }
    
    fileprivate func setUPContinueBtn(){
        if userPhotos.count > 0{
            continueBtn.isEnabled = true //enable contBtn
            continueBtn.backgroundColor = Colors.themeColor.value//UIColor("#00D8FF")
        }else{
            continueBtn.isEnabled = false//disable contBtn
            continueBtn.backgroundColor = UIColor("#D2D2D2")
        }
        
    }
        
    fileprivate func setUpImages(cell:ProfilePictureVCCell , index:Int , photo:Photo){
        
        if selectImage[index] == UIImage(named: "bttn_uploadPhoto")!{
            if let url = URL(string: photo.medium ?? ""){
                cell.pickImageView.kf.indicatorType = .activity
                
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: { [weak self] (result) in
                    if let image = try? result.get().image {
                        cell.pickImageView.image = image
                        self?.selectImage[index] = cell.pickImageView.image!
                    }
                })
                
            }
        }else{
            if let url = URL(string: photo.medium ?? ""){
                cell.pickImageView.kf.indicatorType = .activity
                
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: { [weak self] (result) in
                    if let image = try? result.get().image {
                        cell.pickImageView.image = image
                        self?.selectImage[index] = cell.pickImageView.image!
                    }
                })
                
            }
        }
    }
    
}

//MARK:- Api Calls
extension ProfilePictureVC{
    fileprivate func uploadPhoto(image:Data,imageIndex:Int){
        let isPrimary = imageIndex == 0 ? true : false
        
        self.startAnimation()
        WebServicesManager.shared.uploadPhoto(image : image , isPrimary: isPrimary, order: imageIndex) { (response, error) in
            self.stopAnimation()
            if error == nil{
                self.userPhotos = EntourageManager.shared.photos
                self.setUPContinueBtn()
                self.collectionView.reloadData()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    fileprivate func changeOrder(source:Int , destination:Int){
        let isPrimary = destination == 0 ? true : false
        
            guard let photo1 = userPhotos.first(where: {$0.order == source}) else{
                return
            }
            
            WebServicesManager.shared.setOrderPhotot(photoId : photo1.id  , order: destination, isPrimary: isPrimary) { (response,error)in
                
                if error == nil{
                    
                    self.userPhotos = EntourageManager.shared.photos
                    self.collectionView.reloadData()
                    
                }else{
                    self.collectionView.reloadData()
                    self.showAlert(title: "Error", message: error!)
                }
            }
        
    }

}

//MARK: - Actions
extension ProfilePictureVC{
        
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
                        
            if selectImage[selectedIndexPath.item] != UIImage(named: "bttn_uploadPhoto")!{
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            }

            break
        case .changed:
            
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))

        case .ended:
            
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }

            if selectImage[selectedIndexPath.item] != UIImage(named: "bttn_uploadPhoto")!{
                collectionView.endInteractiveMovement()
            }else{
                collectionView.cancelInteractiveMovement()
            }

        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func pressContinue(_ sender: Any) {
        continueFeedBackBtn(.soft)
        loadCreateUserNameVC(root: false) //load next View Controller
    }
    
}


//MARK: - UICollectionDataSource
extension ProfilePictureVC : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePictureVCCell", for: indexPath) as! ProfilePictureVCCell
        
        if let photo = userPhotos.first(where: {$0.order == indexPath.row}){
            
            self.setUpImages(cell: cell, index: indexPath.row, photo: photo)
            
        }else{
            
            cell.pickImageView.image = UIImage(named: "bttn_uploadPhoto")!
        }
        
        cell.mainSelectionView.isHidden = indexPath.row == 0 ? false : true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 20) / 3 , height: (collectionView.frame.height / 2) - 5)
    }
    
    
}


// MARK: - UICollectionViewDelegate
extension ProfilePictureVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        if indexPath.row != 0 , selectImage[indexPath.row] != UIImage(named: "bttn_uploadPhoto"){
            
        }else{
            selectedCellIndex = indexPath.row
            self.takeImage(imagePicker: imagePicker)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let newIndex = destinationIndexPath.item
        let currIndex = sourceIndexPath.item
        

        if  selectImage[currIndex] != UIImage(named: "bttn_uploadPhoto"),selectImage[newIndex] != UIImage(named: "bttn_uploadPhoto"){
            
            self.changeOrder(source: currIndex , destination: newIndex)
        }else{
                self.collectionView.cancelInteractiveMovement()
        }
        
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ProfilePictureVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage { // from library
            
            
            let data = pickedImage.jpegData(compressionQuality: 0.6)
            
            
            let index = selectedCellIndex == 0 ? 0 : self.userPhotos.count
            
            self.uploadPhoto(image: data! , imageIndex: index  )
            
        }else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{ //from camera
            
            let data = pickedImage.jpegData(compressionQuality: 0.6)
            
            
            let index = selectedCellIndex == 0 ? 0 : self.userPhotos.count
            
            self.uploadPhoto(image: data! , imageIndex: index  )
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
