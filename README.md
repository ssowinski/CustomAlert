# Alert View Controller with Custom Presented View Controller Transition

## Relationships between view controllers

- **Parentage - parent/child** (containment)
A view controller can contain another view controller. Parent view controller (eg. UINavigationController) with a child view controller.

- **Presentation** (modal views)
A view controller can present another view controller. The first view controller is the presenting view controller (not the parent) of the second; the second view controller is the presented view controller (not a child) of the first.


## How a View Controllers gets View 

View controllers load their views lazily. Accessing the view property for the first time loads or creates the view controller’s views. To check whether a view controller has a view not coausing load, call ```isViewLoaded```. In iOS 9, an Optional ```viewIfLoaded``` let as get VC's view if loaded (without loading it). We can load view explicitly, rather than as a side effect of mentioning its view, by calling ```loadViewIfNeeded```.

There are several ways to specify the views for a view controller:
- The view may be created in the view controller’s own code, manually or as as an empty generic view, automatically.
- The view may be created in its own separate nib.
- The view may be created in a nib, which is the same nib from which the view controller itself is instantiated.

#### Create VC's View manually
Implement its ```loadView``` method. Your job here is to obtain an instance of UIView (or a subclass of UIView) and assign it to self.view. You must not call super (for reasons that I’ll make clear later on).

If our ```loadView``` method looks like this:
```
override func loadView() {
    let v = UIView()
    self.view = v
}
```
we can remove its, if no view is supplied in any other way, then UIViewController’s default implementation of ```loadView``` will do exactly what we are already doing in code: it creates a generic UIView object and assigns it to self.view 

> Do not confuse *loadView* with *viewDidLoad*. 
> In *loadView* method, create your view hierarchy programmatically and assign the root view of that hierarchy to the view controller’s view property. *viewDidLoad* is called afterward, when the view is set and it's good place to populate a VC's view.

#### Supplie VC's view from a nib
Create new nib file by File → New → User Interface → View.
In nib interface editor set File's Owner class to UIViewController subclass, then connect File's Owner view outlet to View object.

Now we can crete View Controllesr and associate nib with our View Controler instance.
```
let mainViewController = MainViewController(nibName: "DemoView", bundle: nil)
```

If the nib name passed to init(nibName:bundle:) is nil, a nib will be sought automatically with the same name as the view controller’s class (with and without "Controller" words). Moreover, UIViewController’s init() calls init(nibName:bundle:), passing nil for both arguments.


#### Summary: when the VC's needs view
1. ```loadView``` is called.
2. If we override ```loadView```, we must create the view in code and *don't call super*. 
3. If we don’t override loadView, the default implementation of ```loadView``` loads the VC’s associated nib. (That is why, if we do override loadView, we must not call super) 
4. If we don’t override ```loadView```, and there is no associated nib — US’s default implementation of loadView creates a generic UIView.


#### View size

View controller supplies two properties ```topLayoutGuide``` and ```bottomLayoutGuide```, they help us manage view size having regard bars at the top and bottom of the screen.

A UIViewController receives events that notify it of pending view size changes. 
```
willTransitionToTraitCollection:withTransitionCoordinator:
viewWillTransitionToSize:withTransitionCoordinator:
updateViewConstraints
traitCollectionDidChange:
viewWillLayoutSubviews
viewDidLayoutSubviews
```

## Presented View Controller

The two key methods for presenting and dismissing a view are:

```presentViewController:animated:completion:``` - view controller present another view controller, you send the first view controller this message, handing it the second view controller, which you will instantiate for this purpose. (The first view controller is very typically self.)

```dismissViewControllerAnimated:completion:``` - The “presented” state of affairs described in the previous paragraph persists until the presenting view controller is sent this message. The presented view controller’s view is then removed from the interface, the original interface is restored, and the presented view controller is released; it will thereupon typically go out of existence, together with its view, its child view controllers and their views, and so on.

## Communication With a Presented View Controller
We used designated initializer to pass all data into presented VC during create new instance of presented controller.
```
let alert = SimpleAlertViewController(width: 250, height: 350, titleText: "Uwaga!", mainText: "Podaj imię")
presentViewController(alert, animated:true, completion:nil)
```

To get data from presented VC we use delegate pattern. We can call delegate method on viewWillDisappear or button action
```
override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if self.isBeingDismissed() {
        self.delegate?.acceptData("Even more important data!")
    }
}
```

## Presented View Animation
You can chose built-in animation style setting presented VC ```modalTransitionStyle``` property.
```
.CoverVertical //default
.FlipHorizontal
.CrossDissolve
.PartialCurl
```

## Presentation Styles
To choose a presentation style, set the presented view controller’s ```modalPresentationStyle``` property.
```
.FullScreen //default
.OverFullScreen
.PageSheet
.FormSheet
.CurrentContext
.OverCurrentContext
```

When the presented view controller’s ```modalPresentationStyle``` is ```.CurrentContext``` or ```.OverCurrentContext```, a decision has to be made by the runtime as to what view controller should be the presenting view controller. This will determine what view will be replaced or covered by the presented view controller’s view. The decision involves another UIViewController property, ```definesPresentationContext``` (a Bool), and possibly still another UIViewController property, ```providesPresentationContextTransitionStyle```.

for example, we have UITabBarController with two controllers FirstViewController and SecendViewController. 
Wehen we call

```
let modalVC = ModalViewController()
self.presentViewController(modalVC, animated: true, completion: nil)
```

The presented view controller’s (ModalViewController) view occupies the entire interface, covering even the tab bar; it replaces the root view, because the presentation style is .FullScreen. The presenting view controller is the root view controller, which is the UITabBarController.

but when we call

```
let modalVC = ModalViewController()
self.definesPresentationContext = true // *
modalVC.modalPresentationStyle = .CurrentContext // *
self.presentViewController(modalVC, animated: true, completion: nil)
```
The presented view controller’s view replaces only the first view controller’s view; the tab bar remains, and you can switch back and forth between the tab bar’s first and second views.



## Customize Animation Style & Presentation Styles

Instead of choosing a simple built-in modal presentation style and animation style, you can customize it.


### Customizing the animation


In init instead ```self.modalTransitionStyle = .CoverVertical``` we set ```self.transitioningDelegate = self```
Our class has to confirm UIViewControllerTransitioningDelegate, we have to implement ```animationControllerForPresentedController```. When the transition begins, the delegate will be asked for an animation controller

```
func animationControllerForPresentedController(
    presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
return self
}
```
when we return self we have to confirm UIViewControllerAnimatedTransitioning and implement two methods. (There is no particular reason why the animation controller should be self; it can be 
any object — even a dedicated lightweight object instantiated just to govern this transition.)

``` 
func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.4
}

func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
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
```

## Custom presentation controller

In init we set ```self.modalPresentationStyle = .Custom```

Implement extra delegate method is called so that we can provide a custom presentation controller
```
func presentationControllerForPresentedViewController(
    presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    let pc = MyPresentationController(
    presentedViewController: presented,
    presentingViewController: presenting)
    return pc
}

```

Everything else happens in our implementation of MyPresentationController. 

```
class MyPresentationController : UIPresentationController {
    override func frameOfPresentedViewInContainerView() -> CGRect {
        return super.frameOfPresentedViewInContainerView()
            .insetBy(dx: 40, dy: 40)
    }
    
    override func presentationTransitionWillBegin() {
        let con = self.containerView!
        let shadow = UIView(frame:con.bounds)
        shadow.backgroundColor = UIColor(white:0, alpha:0.4)
        con.insertSubview(shadow, atIndex: 0)
        shadow.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    override func dismissalTransitionWillBegin() {
        let con = self.containerView!
        let shadow = con.subviews[0]
        let tc = self.presentedViewController.transitionCoordinator()!
        tc.animateAlongsideTransition({
            _ in
            shadow.alpha = 0
            }, completion: nil)
    }
    
    override func presentedView() -> UIView? {
        let v = super.presentedView()!
        v.layer.cornerRadius = 6
        v.layer.masksToBounds = true
        return v
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        let vc = self.presentingViewController
        let v = vc.view
        v.tintAdjustmentMode = .Dimmed
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        let vc = self.presentingViewController
        let v = vc.view
        v.tintAdjustmentMode = .Automatic
    }
    
}
```

## View Controller Lifecycle
- Instantiated
- awakeFromNib (all objects that come out of a storyboard)
- segue preparation happens
- outlets get set
- **viewDidLoad**
- These pairs will be called each time your Controller’s view goes on/off screen: 
**viewWillAppear** and **viewDidAppear** ; **viewWillDisappear** and **viewDidDisappear**
- These “geometry changed” methods might be called at any time after viewDidLoad …
**viewWillLayoutSubviews** (… then autolayout happens, then …) **viewDidLayoutSubviews**
- If memory gets low, you might get **didReceiveMemoryWarning**















## Delegation Pattern
A very important use of protocols, implement “blind communication” between a View and its Controller. 

1.Create a delegation protocol.
Defines what the View (CardViewContainer) wants the Controller (WordsListViewController) to take care of.

```sh
protocol CardViewContainerDelegate: class{
    func cardsNumber(cardViewContainer : CardViewContainer) -> Int
    func cardForIndex(cardViewContainer : CardViewContainer, index: Int) -> UIView
}
```

2.Create a delegate property in the View (CardViewContainer) whose type is that delegation protocol

```sh
weak var delegat : CardViewContainerDelegate? {
    didSet {
        showCard(currentIndex, swipeDir: .Left)
    }
}
```
We have to be a little bit careful about delegat because of memory management. When View points Controler and Controler pointer to the View, we create a meory cycle. We used weak to prevent this.

3.Use the delegate property in the View (CardViewContainer) to get/do things it can’t own or control.
We use delegate in few places, e.g. to get card view in showCard.

```sh
private func showCard(index: Int, swipeDir: SwipeDirection) {
    guard let card = delegat?.cardForIndex(self, index: index) else { return }
    addSubview(card)
    .
    .
    .
}
```

4.Controller (WordsListViewController) declares and implements the protocol

```sh
class WordsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ButtonShowMoreDelegate, CardViewContainerDelegate
{
    .
    .
    .
    // MARK: -CardViewContainerDelegate Implemantation
    func cardsNumber(cardViewContainer: CardViewContainer) -> Int {
        return verbsModel.countVerbs()
    }

    func cardForIndex(cardViewContainer: CardViewContainer, index: Int) -> UIView {
        let card = CardView(frame: CGRectMake(0, 0, Const.Size.CardWidth, Const.Size.CardHeight))
        card.verb = verbsModel.getVerb(index)
        return card
    }
}
```

5.Controller (WordsListViewController) sets self as the delegate of the View (CardViewContainer) by setting the property we have created in point 2.

After we create the instance of CardViewContainer, we set self (WordsListViewController) as delegate

```sh
let cardViewContainer = CardViewContainer(frame: self.view.frame, startingIndex: indexPath.row)
cardViewContainer.delegat = self
```
