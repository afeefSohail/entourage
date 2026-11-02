//
//  ViewController+Ext.swift
//  entourage
//

import Foundation
import UIKit

extension BaseVC {

    func useBackButton(image: UIImage?) {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(popToBackViewController(sender:)))
    }

    @objc func popToBackViewController(sender: UIBarButtonItem) {
        sender.isEnabled = false
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    func takeImage(imagePicker: UIImagePickerController) {
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera(imagePicker: imagePicker)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary(imagePicker: imagePicker)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func openCamera(imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary(imagePicker: UIImagePickerController) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
}
