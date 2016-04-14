//
//  SimpleAlertViewController.swift
//  ViewControllersDemo
//
//  Created by Slawomir Sowinski on 09.04.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit
import SnapKit

//'weak' may only be applied to class and class-bound protocol types, not 'SimpleAlertDelegat'
protocol SimpleAlertDelegate: class {
    func alertButton1Action(data: AnyObject?)
    func alertButton2Action(data: AnyObject?)
}

enum SimpleAlertButtonAlignment {
    case Vertical //z gory na dół
    case Horizontal
}

class SimpleAlertViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {
    
    struct Const {
        static let DefaultContainerColor = UIColor(rgb: 0x238888)
        static let DefaultButtonColor = UIColor(rgb: 0x6dc8c9)
        static let DefaultButtonHighlightColor = UIColor(rgb: 0x5eb1b3)
        static let DefaultButtonBorderColor = UIColor.whiteColor()
        static let DefaultAlertTitleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        static let DefaultMainTextFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        static let DefaultTextAlignment = NSTextAlignment.Center
        static let DefaultTextColor = UIColor(rgb: 0xffffff)
        static let MinimumFontScaleFactor: CGFloat = 0.5
        static let DefaultButtonHeight: CGFloat = 50.0
        static let DefaultTextFieldHeight: CGFloat = 40.0
        static let DefaultTextFieldBGColor = UIColor.whiteColor()
        static let Offset: CGFloat = 20
    }
    
    weak var delegate : SimpleAlertDelegate?
    var closeAction:(()->Void)! //or action
    
    private let dismissButton: UIButton = UIButton()
    private let container: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let mainTextLabel: UILabel = UILabel()
    private let buttonContainer = UIView()
    private let button1: UIButton = UIButton()
    private let button2: UIButton = UIButton()
    private let topImage: UIImageView = UIImageView()
    private let bottomImage: UIImageView = UIImageView()
    private let textField: UITextField = UITextField()
    
    private let containerWidth: CGFloat
    private let containerHeight: CGFloat
    
    private let buttonAlignment: SimpleAlertButtonAlignment
    private let button1Height: CGFloat
    private let button2Height: CGFloat
    
    private let textFieldHeight: CGFloat
    
    
    // MARK: - Init
    init(width: CGFloat,
         height: CGFloat,
         containerColor: UIColor = Const.DefaultContainerColor,
         
         titleText: String,
         titleFont: UIFont = Const.DefaultAlertTitleFont,
         titleColor: UIColor = Const.DefaultTextColor,
         titleTextAlignment : NSTextAlignment  = Const.DefaultTextAlignment,
         titleMinScaleFactor : CGFloat = Const.MinimumFontScaleFactor,
         
         mainText: String,
         mainTextFont: UIFont = Const.DefaultMainTextFont,
         mainTextColor: UIColor = Const.DefaultTextColor,
         mainTextAlignment: NSTextAlignment  = Const.DefaultTextAlignment,
         mainTextMinScaleFactor: CGFloat = Const.MinimumFontScaleFactor,
         
         button1Text: String? = nil,
         button2Text: String? = nil,
         buttonColor: UIColor = Const.DefaultButtonColor,
         buttonHighlightColor: UIColor = Const.DefaultButtonHighlightColor,
         buttonBorderColor: UIColor = Const.DefaultButtonBorderColor,
         buttonHeight: CGFloat = Const.DefaultButtonHeight,
         buttonAlignment: SimpleAlertButtonAlignment = .Horizontal,
         
         topImg: UIImage? = nil,
         bootomImg: UIImage? = nil,
         
         textFieldBGColor: UIColor = Const.DefaultTextFieldBGColor,
         textFieldPlaceholder: String? = nil,
         textFieldAlignment: NSTextAlignment  = Const.DefaultTextAlignment,
         textFieldHeight: CGFloat = Const.DefaultTextFieldHeight
        ){
        
        containerWidth = width
        containerHeight = height
        container.backgroundColor = containerColor
        
        titleLabel.text = titleText
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = titleTextAlignment
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = titleMinScaleFactor
        titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(1000, forAxis: .Vertical) //widok nie chce rosnać (wyższy nie rośnie)
        //        titleLabel.backgroundColor = UIColor.brownColor() //usunąć
        
        mainTextLabel.text = mainText
        mainTextLabel.font = mainTextFont
        mainTextLabel.textColor = mainTextColor
        mainTextLabel.textAlignment = mainTextAlignment
        mainTextLabel.adjustsFontSizeToFitWidth = true
        mainTextLabel.minimumScaleFactor = mainTextMinScaleFactor
        mainTextLabel.numberOfLines = 0
        mainTextLabel.setContentHuggingPriority(100, forAxis: .Vertical)
        //        mainTextLabel.backgroundColor = UIColor.blueColor() //usunąć
        
        self.buttonAlignment = buttonAlignment
        let buttonColor = UIImage.withColor(buttonColor)
        let buttonHighlightColor = UIImage.withColor(buttonHighlightColor)
        buttonContainer.backgroundColor = buttonBorderColor
        
        if let txt = button1Text {
            button1.setTitle(txt, forState: .Normal)
            self.button1Height = buttonHeight
            button1.setBackgroundImage(buttonColor, forState: .Normal)
            button1.setBackgroundImage(buttonHighlightColor, forState: .Highlighted)
        } else {
            self.button1Height = 0
        }
        
        if let txt = button2Text {
            button2.setTitle(txt, forState: .Normal)
            self.button2Height = buttonHeight
            button2.setBackgroundImage(buttonColor, forState: .Normal)
            button2.setBackgroundImage(buttonHighlightColor, forState: .Highlighted)
        } else {
            self.button2Height = 0
        }
        
        if let img = topImg {
            topImage.image = img
        }
        
        if let img = bootomImg {
            bottomImage.image = img
        }
        
        
        if let txt = textFieldPlaceholder {
            //        textField.borderStyle = UITextBorderStyle.Line
            self.textFieldHeight = textFieldHeight
            textField.textAlignment = textFieldAlignment
            textField.placeholder = txt
            textField.backgroundColor = textFieldBGColor
        } else {
            self.textFieldHeight = 0
        }
        
        dismissButton.setTitle("X", forState: .Normal)
        //        dismissButton.setImage(UIImage(named: Const.String.SpeakButtonImg), forState: UIControlState.Normal)
        
        super.init(nibName: nil, bundle: nil)
        
        
//                self.modalTransitionStyle = .CoverVertical
        self.transitioningDelegate = self //UIViewControllerTransitioningDelegate need to create Custom Transition Animation
        self.modalPresentationStyle = .OverCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //-------------- to Custom Transition Animation ----------------
    
    // UIViewControllerTransitioningDelegate implementation
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
                             sourceController source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return self
    }
    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
    
    //UIViewControllerAnimatedTransitioning implementation
    func transitionDuration(
        transitionContext: UIViewControllerContextTransitioning?)
        -> NSTimeInterval {
            return 0.4
    }
    
    func animateTransition(
        transitionContext: UIViewControllerContextTransitioning) {
        let vc2 = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let con = transitionContext.containerView()!
        let r2end = transitionContext.finalFrameForViewController(vc2!)
        let v1 = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let v2 = transitionContext.viewForKey(UITransitionContextToViewKey)
        if let v2 = v2 { // presenting
            v2.frame = r2end
            v2.transform = CGAffineTransformMakeScale(0.1, 0.1)
            v2.alpha = 0
            con.addSubview(v2)
            UIView.animateWithDuration(0.4, animations: {
                v2.alpha = 1
                v2.transform = CGAffineTransformIdentity
                }, completion: {
                    _ in
                    transitionContext.completeTransition(true)
            })
        } else if let v1 = v1 { //dismissing
            
            // ... 
        }
        
        
    }
    
    //-------------- END to Custom Transition Animation ----------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        // Do any additional setup after loading the view.
    }
    
    
    private func layoutUI() {
        dismissButton.addTarget(self, action: #selector(SimpleAlertViewController.dismissAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        button1.addTarget(self, action: #selector(SimpleAlertViewController.button1Action(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        button2.addTarget(self, action: #selector(SimpleAlertViewController.button2Action(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(container)
        view.addSubview(dismissButton)
        container.addSubview(titleLabel)
        container.addSubview(topImage)
        container.addSubview(mainTextLabel)
        container.addSubview(bottomImage)
        container.addSubview(textField)
        container.addSubview(buttonContainer)
        buttonContainer.addSubview(button1)
        buttonContainer.addSubview(button2)
        
        container.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.lessThanOrEqualTo(containerWidth)
            make.height.lessThanOrEqualTo(containerHeight)
        }
        
        dismissButton.snp_makeConstraints { (make) in
            make.left.equalTo(container.snp_right)
            make.bottom.equalTo(container.snp_top)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.left.equalTo(container).offset(Const.Offset)
            make.right.equalTo(container).offset(-Const.Offset)
            make.bottom.equalTo(topImage.snp_top).offset(-Const.Offset/2)
        }
        
        topImage.snp_makeConstraints { (make) in
            make.centerX.equalTo(container.snp_centerX)
            make.bottom.equalTo(mainTextLabel.snp_top).offset(-Const.Offset/2)
        }
        
        mainTextLabel.snp_makeConstraints { (make) in
            make.left.equalTo(container).offset(Const.Offset)
            make.right.equalTo(container).offset(-Const.Offset)
            make.bottom.equalTo(bottomImage.snp_top).offset(-Const.Offset/2)
        }
        
        bottomImage.snp_makeConstraints { (make) in
            make.centerX.equalTo(container.snp_centerX)
            make.bottom.equalTo(textField.snp_top).offset(-Const.Offset/2)
        }
        
        textField.snp_makeConstraints { (make) in
            make.left.equalTo(container)
            make.right.equalTo(container)
            make.bottom.equalTo(buttonContainer.snp_top).offset(-Const.Offset/2)
            make.height.equalTo(textFieldHeight)
        }
        
        buttonContainer.snp_makeConstraints { (make) in
            make.left.equalTo(container)
            make.right.equalTo(container)
            make.bottom.equalTo(container)
            make.height.equalTo(button1Height > button2Height ? button1Height + 1 : button2Height + 1)
        }
        
        let buttonSeparator = UIView()
        buttonContainer.addSubview(buttonSeparator)
        buttonSeparator.snp_makeConstraints { (make) in
            make.left.equalTo(button1.snp_right)
            make.right.equalTo(button2.snp_left)
            make.width.greaterThanOrEqualTo(1)
        }
        
        button1.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(buttonContainer)
            //            make.right.equalTo(buttonContainer.snp_centerX).offset(-0.5)
            make.bottom.equalTo(buttonContainer)
            make.height.equalTo(button1Height)
            if button1Height == 0 {
                make.width.equalTo(0)
            }
        })
        
        button2.snp_makeConstraints(closure: { (make) in
            make.right.bottom.equalTo(buttonContainer)
            //            make.left.equalTo(buttonContainer.snp_centerX).offset(0.5)
            make.height.equalTo(button2Height)
            if button2Height == 0 {
                make.width.equalTo(0)
            }
        })
        
        //        button1.snp_makeConstraints(closure: { (make) in
        //            make.left.equalTo(container)
        //            make.right.equalTo(container)
        //            make.bottom.equalTo(button2.snp_top)
        //            make.height.equalTo(button1Height)
        //        })
        //
        //        button2.snp_makeConstraints(closure: { (make) in
        //            make.left.equalTo(container)
        //            make.right.bottom.equalTo(container)
        //            make.height.equalTo(button2Height)
        //        })
        
    }
    
    func dismissAction(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func button1Action(sender: UIButton) {
        delegate?.alertButton1Action(nil)
    }
    
    func button2Action(sender: UIButton) {
        delegate?.alertButton2Action(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: - UIViewControllerTransitioningDelegate Implementation
    
    
}

// See: http://stackoverflow.com/questions/20300766/how-to-change-the-highlighted-color-of-a-uibutton
extension UIImage {
    class func withColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat = CGFloat(1.0)) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//The Swift Programming Language Guide - Advanced Operators
//https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html

//let pink: UInt32 = 0xCC6699
//let redComponent = (pink & 0xFF0000) >> 16    // redComponent is 0xCC, or 204
//let greenComponent = (pink & 0x00FF00) >> 8   // greenComponent is 0x66, or 102
//let blueComponent = pink & 0x0000FF           // blueComponent is 0x99, or 153
//
//This example uses a UInt32 constant called pink to store a Cascading Style Sheets color value for the color pink. The CSS color value #CC6699 is written as 0xCC6699 in Swift’s hexadecimal number representation. This color is then decomposed into its red (CC), green (66), and blue (99) components by the bitwise AND operator (&) and the bitwise right shift operator (>>).
//
//The red component is obtained by performing a bitwise AND between the numbers 0xCC6699 and 0xFF0000. The zeros in 0xFF0000 effectively “mask” the second and third bytes of 0xCC6699, causing the 6699 to be ignored and leaving 0xCC0000 as the result.
//
//This number is then shifted 16 places to the right (>> 16). Each pair of characters in a hexadecimal number uses 8 bits, so a move 16 places to the right will convert 0xCC0000 into 0x0000CC. This is the same as 0xCC, which has a decimal value of 204.
//
//Similarly, the green component is obtained by performing a bitwise AND between the numbers 0xCC6699 and 0x00FF00, which gives an output value of 0x006600. This output value is then shifted eight places to the right, giving a value of 0x66, which has a decimal value of 102.
//
//Finally, the blue component is obtained by performing a bitwise AND between the numbers 0xCC6699 and 0x0000FF, which gives an output value of 0x000099. There’s no need to shift this to the right, as 0x000099 already equals 0x99, which has a decimal value of 153.



