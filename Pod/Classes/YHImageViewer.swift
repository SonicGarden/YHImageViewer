//
//  YHImageViewer.swift
//  YHImageViewer
//
//  Created by yuyahirayama on 2015/07/19.
//  Copyright (c) 2015年 Yuya Hirayama. All rights reserved.
//

import UIKit

open class YHImageViewer: NSObject {

    fileprivate var window:UIWindow!
    fileprivate var backgroundView:UIView!
    fileprivate var imageView:UIImageView!
    fileprivate var startFrame:CGRect!

    open var backgroundColor:UIColor?
    open var fadeAnimationDuration:TimeInterval = 0.15

    open func show(_ targetImageView:UIImageView) {

        // Create UIWindow
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert
        let windowTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(YHImageViewer.windowTapped(_:)))
        window.addGestureRecognizer(windowTapRecognizer)
        self.window = window
        window.makeKeyAndVisible()


        // Initialize background view
        let backgroundView = UIView()
        if let color = self.backgroundColor {
            backgroundView.backgroundColor = color
        } else {
            backgroundView.backgroundColor = UIColor.black
        }
        backgroundView.frame = self.window.bounds
        backgroundView.alpha = 0
        self.window.addSubview(backgroundView)
        self.backgroundView = backgroundView


        // Initialize UIImageView
        let image = targetImageView.image
        if image == nil {
            fatalError("UIImageView is not initialized correctly.")
        }

        let imageView = UIImageView(image: image)
        self.imageView = imageView
        let startFrame = targetImageView.convert(targetImageView.bounds, to: self.backgroundView)
        self.startFrame = startFrame
        imageView.frame = startFrame
        self.backgroundView.addSubview(imageView)


        // Initialize drag gesture recognizer
        let imageDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(YHImageViewer.imageDragged(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imageDragRecognizer)

        // Initialize pinch gesture recognizer
        let imagePinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(YHImageViewer.imagePinched(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imagePinchRecognizer)


        // Start animation
        UIView.animate(withDuration: self.fadeAnimationDuration, animations: { () -> Void in
            backgroundView.alpha = 1
            }, completion: { (_) -> Void in
                self.moveImageToCenter()
        }) 
    }

    func moveImageToCenter() {
        if let imageView = self.imageView {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                let width = self.window.bounds.size.width
                let height = width / imageView.image!.size.width * imageView.image!.size.height
                self.imageView.frame.size = CGSize(width: width, height: height)
                self.imageView.center = self.window.center
                }, completion: { (_) -> Void in
                    self.adjustBoundsAndTransform(self.imageView)
            }) 
        }
    }

    func windowTapped(_ recognizer:UIGestureRecognizer) {
        self.moveToFirstFrame { () -> Void in
            self.close()
        }
//        self.debug()
    }

    func imageDragged(_ recognizer:UIPanGestureRecognizer) {
        switch (recognizer.state) {
        case .changed:
            // Move target view
            if let targetView = recognizer.view {
                let variation = recognizer.translation(in: targetView)
                targetView.center = CGPoint(x: targetView.center.x + variation.x * targetView.transform.a, y: targetView.center.y + variation.y * targetView.transform.a)

                let velocity = recognizer.velocity(in: targetView)
            }
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)

        case .ended:
            // Check velocity
            if let targetView = recognizer.view {
                let variation = recognizer.translation(in: targetView)
                let velocity = recognizer.velocity(in: targetView)
                let straightVelocity = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
                let velocityThreshold = 1000
                let goalPointRate = 5000.0
                if straightVelocity > 1000 {
                    let radian = atan2(velocity.y, velocity.x)
                    let goalPoint = CGPoint(x: cos(radian) * CGFloat(goalPointRate), y: sin(radian) * CGFloat(goalPointRate))
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        targetView.center = goalPoint
                    }, completion: { (_) -> Void in
                        self.close()
                    })
                } else {
                    self.adjustImageViewFrame()
                }
            }
        default:
            _ = 0
        }
        self.debug()
    }

    func imagePinched(_ recognizer:UIPinchGestureRecognizer) {
        let targetView = recognizer.view!
        let scale = recognizer.scale
        let velocity = recognizer.velocity
        let point = recognizer.location(in: targetView)
        switch (recognizer.state) {
        case .changed:
            let transform = targetView.transform.a
            targetView.transform = CGAffineTransform(scaleX: scale, y: scale)
        case .ended , .cancelled:
            let center = targetView.center
            self.adjustBoundsAndTransform(targetView)
            self.adjustImageViewFrame()
        default:
            _ = 0
        }
        self.debug()
    }

    func close() {
        UIView.animate(withDuration: self.fadeAnimationDuration, animations: { () -> Void in
            self.backgroundView.alpha = 0
            }, completion: { (_) -> Void in
                self.window = nil
        }) 
    }

    func moveToFirstFrame(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.imageView.frame = self.startFrame
            }, completion: { (_) -> Void in
                completion()
        }) 
    }

    func debug() {
//        println("frame: \(self.imageView.frame) bounds: \(self.imageView.bounds) center: \(self.imageView.center) transform: \(self.imageView.transform.a)")
    }

    func adjustBoundsAndTransform(_ view: UIView) {
        let center = view.center
        let scale = view.transform.a
        view.bounds.size = CGSize(width: view.bounds.size.width * scale, height: view.bounds.size.height * scale)
        view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        view.center = center
    }

    func isImageSmallerThanScreen() -> Bool {
        let imageWidth = self.imageView.frame.size.width
        let imageHeight = self.imageView.frame.size.height
        let screenWidth = self.window.bounds.size.width
        let screenHeight = self.window.bounds.size.height

        return imageWidth <= screenWidth && imageHeight <= screenHeight
    }

    func adjustImageViewFrame() {
        if self.isImageSmallerThanScreen() {
            self.moveImageToCenter()
            return
        }

        let targetView = self.imageView

        var originX:CGFloat = targetView!.frame.origin.x
        var originY:CGFloat = targetView!.frame.origin.y
        var animateX = true
        var animateY = true
        if (targetView!.frame.origin.x > CGFloat(0) ) {
            originX = 0
        } else if ((targetView?.frame.origin.x)! < self.window.bounds.width - (targetView?.bounds.size.width)!) {
            originX = self.window.bounds.width - (targetView?.bounds.size.width)!
        }else {
            animateX = false
        }
        if ((targetView?.bounds.size.height)! < self.window.bounds.size.height) {
            originY = (self.window.bounds.size.height - (targetView?.bounds.size.height)!)/2
        } else if targetView!.frame.origin.y > CGFloat(0) {
            originY = 0
        } else if (targetView?.frame.origin.y)! + (targetView?.bounds.size.height)! < self.window.bounds.height {
            originY = self.window.bounds.size.height - (targetView?.bounds.size.height)!
        }
        else {
            animateY = false
        }
        if animateX || animateY {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                targetView?.frame = CGRect(x: originX, y: originY, width: (targetView?.bounds.size.width)!, height: (targetView?.bounds.size.height)!)
                }, completion: { (_) -> Void in

            })
        }
    }
}
