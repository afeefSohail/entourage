//
//  EditProfileVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/14/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class EditProfileVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var bioDetailLabel: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeholderLbl: UILabel!
    
    //MARK:- Class Properties
    var imagePicker = UIImagePickerController()
    //bttn_uploadPhoto
    var selectImage : [UIImage] = [UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")!,
                                   UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")!,
                                   UIImage(named: "bttn_uploadPhoto")!,UIImage(named: "bttn_uploadPhoto")! ]
    
    var userPhotos = EntourageManager.shared.photos
    var callback : PressOkay!
    var selectedCellIndex = 0
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override func setupGUI() {
        super.setupGUI()
        
        title = "Edit Profile"

        hideNavBar()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
                
        //set the imagePickerDelegate
        imagePicker.delegate = self
        
        bioDetailLabel.text = EntourageManager.shared.user.bio ?? ""
        placeholderLbl.isHidden = bioDetailLabel.text.count > 0 ? true : false
        
        
    }
    
    override func updateGUI() {
        Utils.currVC = self
    }
    
    fileprivate func uploadPhoto(image:Data,imageIndex:Int){
        let isPrimary = imageIndex == 0 ? true : false
        
            self.startAnimation()
            WebServicesManager.shared.uploadPhoto(image : image , isPrimary: isPrimary, order: imageIndex) { (response, error) in
                self.stopAnimation()
                if error == nil{
                    self.userPhotos = EntourageManager.shared.photos
                    self.callback()
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
                    self.callback()

                    self.collectionView.reloadData()
                    
                }else{
                    self.collectionView.reloadData()
                    self.showAlert(title: "Error", message: error!)
                }
            }
        
    }
    
    fileprivate func deletImages(tag:Int){
        
        let alert = UIAlertController(title: "Delete Photo" , message: "Are you sure you want to delete this photo?" , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            guard let photo = self.userPhotos.first(where: {$0.order == tag}) else{
                return
            }
            
            self.startAnimation()
            WebServicesManager.shared.deletePhotot(photoId: photo.id ) { (response, error) in
                self.stopAnimation()
                if error == nil{
                    self.userPhotos = EntourageManager.shared.photos
                    self.selectImage[tag] = UIImage(named: "bttn_uploadPhoto")!
                    self.collectionView.reloadData()
                    self.callback()
                    
                }else{
                    self.collectionView.reloadData()
                    self.showAlert(title: "Error", message: error!)
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    fileprivate func setUpImages(cell:EditProfileVCCell , index:Int , photo:Photo){
        
        if selectImage[index] == UIImage(named: "bttn_uploadPhoto")!{
            if let url = URL(string: photo.medium ?? ""){
                cell.pickImageView.kf.indicatorType = .activity
                
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: { [weak self] (result) in
                    if let image = try? result.get().image {
                        cell.pickImageView.image = image
                        self?.selectImage[index] = cell.pickImageView.image!
                    }
                })
                cell.deletBtn.isHidden = index == 0 ? true : false
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
                cell.deletBtn.isHidden = index == 0 ? true : false
            }
        }
    }
}

// MARK: - Actions
extension EditProfileVC{
    
    @IBAction func pressSaveBtn(_ sender: Any) {
        EntourageManager.shared.user.bio = bioDetailLabel.text
        self.startAnimation()
        WebServicesManager.shared.editUserProfile(checkAge: false ) { (user, error) in
            self.stopAnimation()
            
            if error == nil {
                self.callback()
                self.navigationController?.popViewController(animated: true)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    @objc func pressDeleteBtn(_ sender:UIButton){
        self.deletImages(tag: sender.tag)
    }
    
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
    
}


//MARK: - UICollectionDataSource
extension EditProfileVC : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditProfileVCCell", for: indexPath) as! EditProfileVCCell
        
            if let photo = userPhotos.first(where: {$0.order == indexPath.row}){
                
                self.setUpImages(cell: cell, index: indexPath.row, photo: photo)
                
            }else{
                
                cell.pickImageView.image = UIImage(named: "bttn_uploadPhoto")!
                cell.deletBtn.isHidden =  true
            }
            
//}
        cell.deletBtn.tag = indexPath.row
        cell.mainSelectionView.isHidden = indexPath.row == 0 ? false : true
        cell.deletBtn.addTarget(self, action: #selector(pressDeleteBtn), for: .touchUpInside)
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 10) / 3 , height: (collectionView.frame.height / 2) - 5)
    }
    

}


// MARK: - UICollectionViewDelegate
extension EditProfileVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCellIndex = indexPath.row
        
        if selectedCellIndex != 0 , selectImage[selectedCellIndex] != UIImage(named: "bttn_uploadPhoto"){
            
        }else{
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
    extension EditProfileVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
        
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

extension EditProfileVC : UITextViewDelegate{
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLbl.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        bioDetailLabel.text = textView.text
        placeholderLbl.isHidden = bioDetailLabel.text.count > 0 ? true : false
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // why the fuck you are saving the bio when user tap on done button only?
        bioDetailLabel.text = textView.text
//        placeholderLbl.isHidden = bioDetailLabel.text.count > 0 ? true : false

        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
}


