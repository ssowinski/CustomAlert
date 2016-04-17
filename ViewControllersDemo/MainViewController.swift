//
//  ViewController.swift
//  ViewControllersDemo
//
//  Created by Slawomir Sowinski on 09.04.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SimpleAlertDelegate {
    
    private struct Const {
        static let Title = "Alert Demo"
        static let CellReusedIdentifier = "cellReusedIdentifier"
        static let BgColor = UIColor(rgb: 0xCECED2)
        
        // Alert Settings
        static let Width: CGFloat = 300
        static let Height: CGFloat = 550
        static let TitleText = "UWAGA! \n nowa wiadomość"
        static let MainText = "Na dobranoc - dobry wieczór \n miś pluszowy śpiewa Wam. Mówią o mnie Miś Uszatek, bo klapnięte uszko mam. "
        static let Button1Txt = "Ustaw"
        static let Button2Txt = "Anuluj"
        static let Button3Txt = "Bardzo długi tekst na przycisku, który zostanie zmniejszony."
        static let Img1 = UIImage(named: "img1")
        static let Img2 = UIImage(named: "img2")
        static let disImg1 = UIImage(named: "close1")
        static let disImg2 = UIImage(named: "close2")
        static let TextFieldPlaceholder = "Proszę podać imię"
        
    }
    
    private let cellLabels = ["no buttons", "one button", "two buttons", "three buttons", "three buttons (in columne)", "two buttons & img", "two buttons & two imgs", "buttons & imgs & textFields"]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Const.CellReusedIdentifier)
            tableView.backgroundColor = Const.BgColor
        }
    }
    
    //MARK - SimpleAlertDelegate Implementation
    func alertButtonAction(data: AnyObject?, sender: UIButton?) {
        print("Przycisk nr \((sender?.tag)! + 1)")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK - TableView Delegat & DataSource Implementation
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLabels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Const.CellReusedIdentifier)
        cell?.contentView.backgroundColor = Const.BgColor
        cell?.textLabel?.text = cellLabels[indexPath.row]
        cell?.textLabel?.textAlignment = .Center
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let alert : SimpleAlertViewController?
        
        switch indexPath.row {
        case 1: //one button
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt], dismissImg: Const.disImg2)
        
        case 2: //two buttons
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button3Txt])
            
        case 3: //three buttons
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button2Txt, Const.Button1Txt])
        
        case 4: //three buttons (in Column)
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button2Txt, Const.Button3Txt], buttonAlignment: .InColumn)

        case 5: //two buttons & img
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button2Txt], topImg: Const.Img2)
            
        case 6: //two buttons & two imgs
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button2Txt], topImg: Const.Img1, bootomImg: Const.Img2)
            
        case 7: //two buttons & two imgs & textField
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, buttonsText: [Const.Button1Txt, Const.Button2Txt], topImg: Const.Img1, bootomImg: Const.Img2, textFieldPlaceholder: Const.TextFieldPlaceholder)
            
        default: //only title and text
            alert = SimpleAlertViewController(maxWidth: Const.Width, maxHeight: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, dismissImg: Const.disImg1)
        }
        
        if let alert = alert {
            alert.delegate = self
            presentViewController(alert, animated:true, completion:nil)
        }
    }
    
    //MARK - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Const.BgColor
        title = Const.Title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

