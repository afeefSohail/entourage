//
//  BaseVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices

class BaseVC: UIViewController{

    
    var activtyIndicator = MyActivityIndicator(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    
    //MARK: - Basic Functions
    func setupGUI() -> Void {
    }
    
    func updateGUI() -> Void {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setNavigationBackButtonColor() {
        navigationItem.backBarButtonItem?.tintColor = UIColor.init(red: 255/255.0, green: 190/255.0, blue: 75/255.0, alpha: 1.0)
    }
    
    func setUpNavigationBar(){
        
        navigationController?.navigationBar.barTintColor = UIColor.white//background color
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-BlackOblique", size: 18)!]
    }
    
    func hideNavBar() {
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavBar() {
        //self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func addNavBarShadow(){
        self.navigationController?.navigationBar.setTopNavBarShadow()
    }

    func removeNavBarShadow(){
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backBtnPressed(sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, message: String) -> Void {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
        
    var defaultStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    //MARK: - UIFeedbackGenerator
    func continueFeedBackBtn(_ style:UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notificationFeedBackBtn(_ type:UINotificationFeedbackGenerator.FeedbackType){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func loadExtrenal(url:String){
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = vc as? SFSafariViewControllerDelegate
            self.present(vc, animated: true)
        }
    }
    
}


// MARK: - NVActivityIndicatorViewable
extension BaseVC : NVActivityIndicatorViewable{
    
    //UIColor("#04D88E")
    func startAnimation() {
        
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.addSubview(activtyIndicator)
        activtyIndicator.inidicator.startAnimating()
    }
    
//Colors.themeColor.value
    func start_Animation() {
        startAnimating(CGSize(width: 60, height: 60), message: "", messageFont: UIFont.boldSystemFont(ofSize: 10), type: .ballScaleMultiple, color:  .white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor.black.withAlphaComponent(0.5), textColor: .white, fadeInAnimation: nil)
        
    }

    func stop_Animation(){
        stopAnimating()
    }

    func stopAnimation(){
        activtyIndicator.inidicator.stopAnimating()
        
        activtyIndicator.removeFromSuperview()
        //self.stopAnimating()
    }

}
