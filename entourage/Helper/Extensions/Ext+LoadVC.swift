//
//  Ext+LoadVC.swift
//  entourage
//

import UIKit
import SwiftUI

extension UIViewController {
    
    // MARK: - OnBoarding Controllers
    
    func loadTutorialVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
        self.navigationController?.show(tutorialVC, sender: nil)
    }

    func loadPhoneNumVerifyVC() {
        let loginVC = UIStoryboard(name: "onBoarding", bundle: nil).instantiateViewController(identifier: "PhoneNumVerifyVC") as! PhoneNumVerifyVC
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }

    func loadVerifyPinVC(phoneNumber: String) {
        let verifyPinVC = UIStoryboard(name: "onBoarding", bundle: nil).instantiateViewController(identifier: "VerifyPinVC") as! VerifyPinVC
        verifyPinVC.modalPresentationStyle = .fullScreen
        verifyPinVC.userPhone = phoneNumber
        self.show(verifyPinVC, sender: nil)
    }

    func loadGenderSelectedVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let genderSelectionVC = storyboard.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController = UINavigationController(rootViewController: genderSelectionVC)
    }

    func loadProfilePictureVC(root: Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let profilePictureVC = storyboard.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
        if root {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.rootViewController = UINavigationController(rootViewController: profilePictureVC)
            profilePictureVC.setUpNavigationBar()
        } else {
            self.navigationController?.show(profilePictureVC, sender: nil)
        }
    }

    func loadCreateUserNameVC(root: Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let createUserNameVC = storyboard.instantiateViewController(withIdentifier: "CreateUserNameVC") as! CreateUserNameVC
        if root {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.rootViewController = UINavigationController(rootViewController: createUserNameVC)
            createUserNameVC.setUpNavigationBar()
        } else {
            self.navigationController?.show(createUserNameVC, sender: nil)
        }
    }

    func loadContactPermissionVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let contactPermissionVC = storyboard.instantiateViewController(withIdentifier: "ContactPermissionVC") as! ContactPermissionVC
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController = UINavigationController(rootViewController: contactPermissionVC)
    }

    func loadAddFirstNameVC(vcType: Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addFirstNameVC = storyboard.instantiateViewController(withIdentifier: "AddFirstNameVC") as! AddFirstNameVC
        addFirstNameVC.vcType = vcType
        self.navigationController?.show(addFirstNameVC, sender: nil)
    }

    func loadAddBirthdayDateVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addBirthdayDateVC = storyboard.instantiateViewController(withIdentifier: "AddBirthdayDateVC") as! AddBirthdayDateVC
        self.navigationController?.show(addBirthdayDateVC, sender: nil)
    }

    func loadAddFriendsVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addFriendsVC = storyboard.instantiateViewController(withIdentifier: "AddFriendsVC") as! AddFriendsVC
        self.navigationController?.show(addFriendsVC, sender: nil)
    }
}

extension UIButton {

    func getContinueAttributedText() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "Continue with Phone Number", attributes: [
            .font: UIFont(name: "HelveticaNeue", size: 16.0)!,
            .foregroundColor: UIColor(white: 1.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, range: NSRange(location: 14, length: 12))
        return attributedString
    }

    func selectedGenderBtn() {
        self.borderColor = UIColor("#00D8FF")
        self.setTitleColor(UIColor("#00D8FF"), for: .normal)
        self.isSelected = true
    }

    func unSelectGender() {
        self.borderColor = UIColor("#D8D8D8")
        self.setTitleColor(UIColor("#D8D8D8"), for: .normal)
        self.isSelected = false
    }
}

extension UILabel {

    func getPrivacyLabel() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "By continuing, you agree to both our\n \nTerms and Privacy Policy", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
            .foregroundColor: UIColor(red: 49.0/255.0, green: 66.0/255.0, blue: 89.0/255.0, alpha: 1.0),
            .kern: 0.51
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(white: 0.0, alpha: 1.0), range: NSRange(location: 39, length: 24))
        attributedString.addAttribute(.link, value: "https://www.google.com", range: NSRange(location: 39, length: 5))
        attributedString.addAttribute(.link, value: "https://www.google.com", range: NSRange(location: 49, length: 14))
        return attributedString
    }

    func getInterestLabel() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "Select up to 3 that discribe you best ", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 16.0)!,
            .foregroundColor: UIColor(white: 155.0/255.0, alpha: 1.0),
            .kern: -0.12
        ])
        attributedString.addAttributes([
            .font: UIFont(name: "Avenir-BlackOblique", size: 16.0)!,
            .foregroundColor: UIColor(red: 48.0/255.0, green: 83.0/255.0, blue: 1.0, alpha: 1.0)
        ], range: NSRange(location: 13, length: 1))
        return attributedString
    }
}
