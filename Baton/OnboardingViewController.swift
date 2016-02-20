//
//  OnboardingViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController {

    // MARK: - Variables
    // Makes array of View Controllers
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController("Onboarding1"),
            self.newColoredViewController("Onboarding2"),
            self.newColoredViewController("Onboarding3"),
            self.newColoredViewController("Push")]
    }()
    
    // Instantiates View Controller with the given Storyboard ID
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(color)ViewController")
    }
    
    
    // MARK: - viewWill/viewDid
    // Finds UIPageControl view and then changes the background color
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view.isKindOfClass(UIScrollView) {
                view.frame = UIScreen.mainScreen().bounds
            } else if view.isKindOfClass(UIPageControl) {
                view.backgroundColor = UIColor(white:0.65, alpha:0.7)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set delegate of UIPageViewController
        dataSource = self
        
        // Goes to firstViewController in the orderedList above
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}


// Extension used to edit UIPageViewController DataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    // Set up the View Controller before
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // Index cannot be lower than 0
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    // Set up the View Controller after
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // Last Index must be -1 of count
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    // Return the count of View Controllers
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    // Makes the first view controller the first view controller in the ordered Array
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
