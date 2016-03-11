//
//  VideoPageViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/9/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class VideoPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var pageViewController: UIPageViewController?
    var interactor:Interactor? = nil
    var answers: [Answer]!
    var indexPath = 0
    var fromFollowing = false
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
    }
    
    func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoPageVC") as! UIPageViewController
        
        pageController.dataSource = self
        
        if answers.count > 0 {
            let firstController = getItemController(indexPath)!
            firstController.firstVC = true
            let startingViewControllers: NSArray = [firstController as VideoViewController]
            pageController.setViewControllers(startingViewControllers as! [VideoViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        
        pageViewController!.didMoveToParentViewController(self)
        self.view.addSubview(pageViewController!.view)
        
    }
    
    private func setupPageControl() {
        
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! VideoViewController
        
        if itemController.indexPath > 0 {
            return getItemController(itemController.indexPath-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//        let count = answers.count - 1
//        let lastVC = pendingViewControllers[count]
//        
//        if indexPath == count {
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! VideoViewController
        
        if itemController.indexPath+1 < answers.count {
            return getItemController(itemController.indexPath+1)
        }
//        else if itemController.indexPath+1 < answers.count {
//            return viewController
//        }
        
        return nil
    }
    
    
    
    private func getItemController(itemIndex: Int) -> VideoViewController? {
        
        if itemIndex < answers.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoVC") as! VideoViewController
            pageItemController.answer = answers[itemIndex]
//            pageItemController.videoUrl = answers[itemIndex].video_url
//            pageItemController.vertical_screen = answers[itemIndex].vertical_screen
            pageItemController.indexPath = itemIndex
            pageItemController.fromFollowing = fromFollowing
            pageItemController.interactor = interactor
            if itemIndex == 0 {
                pageItemController.firstIndex = true
                if answers.count == 1 {
                    pageItemController.oneVC = true
                }
            } else if itemIndex == (answers.count-1) {
                pageItemController.lastIndex = true
            }
            return pageItemController
        }
        
        return nil
    }
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        
//        return answers.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return indexPath
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
//        setupPageControl()
//        createPageViewController()
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        print("Reached")
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }
    
    
    

}

