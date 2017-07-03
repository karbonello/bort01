//
//  BuffViewController.swift
//  Taxi for rider
//
//  Created by Chingis on 30.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit

class BuffViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController?
    
    let contentImages = ["carIcon0", "carIcon1", "carIcon2", "carIcon3"]
    
    var categories = [CarCategory]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //customizeNavBar()
        categories = CarCategory.createCarCategory()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        createPageViewController()
        setupPageControl()
    }
    
    
    /*func customizeNavBar() {
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPageViewController() {
        let pageController = self.storyboard?.instantiateViewController(withIdentifier: "PageController") as! UIPageViewController
        
        pageController.dataSource = self
        
        if categories.count > 0 {
            
            let firstController = getChooserController(categories.count - 1)!
            let starringViewControllers = [firstController]
            
            pageController.setViewControllers(starringViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.backgroundColor = UIColor.clear
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! CarChooserViewController
        
        if itemController.itemIndex > 0 {
            return getChooserController(itemController.itemIndex - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! CarChooserViewController
        
        if itemController.itemIndex > 0 {
            return getChooserController(itemController.itemIndex - 1)
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return categories.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func currentControllerIndex() -> Int {
        let carChooserController = self.currentControllerIndex()
        if let controller = carChooserController as? CarChooserViewController {
            return controller.itemIndex
        }
        return 3
    }
    
    func currentController() -> UIViewController? {
        if (self.pageViewController?.viewControllers?.count)! > 0 {
            return self.pageViewController?.viewControllers![0]
        }
        return nil
    }
    
    public func dismissThisView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getChooserController(_ itemIndex: Int) -> CarChooserViewController? {
        if itemIndex < categories.count {
            let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "CarChooserController") as! CarChooserViewController
            
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = categories[itemIndex].categoryImage!
            pageItemController.categoryName = categories[itemIndex].categoryName!
            pageItemController.categoryPrice = categories[itemIndex].categoryPrice!
            pageItemController.categoryCarModel = categories[itemIndex].categoryCarName!
            return pageItemController
        }
        return nil
    }


}
