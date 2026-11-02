//
//  Ext+LoadVC.swift
//  entourage
//

import UIKit
import SwiftUI

extension UIViewController {}

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
