//
//  SegmentVC.swift
//  entourage
//
//  Created by afeef sohail on 9/8/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class SegmentVC: UIPageViewController {

    //MARK: - IBOutLets
    
    //MARK: - Class Properties
    var subControllers:[UIViewController] = []
    var menuBarSelectedIndex = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        dataSource = self
    }

    
}


// MARK: UIPageViewControllerDataSource

extension SegmentVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}
