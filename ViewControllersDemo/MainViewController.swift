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
        static let Img1 = UIImage(named: "img1")
        static let Img2 = UIImage(named: "img2")
        static let TextFieldPlaceholder = "Proszę podać imię"
        
    }
    
    private let cellLabels = ["no buttons", "one button", "two buttons", "two buttons & img", "two buttons & two imgs", "all"]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Const.CellReusedIdentifier)
            tableView.backgroundColor = Const.BgColor
        }
    }
    
    //MARK - SimpleAlertDelegate Implementation
    func alertButton1Action(data: AnyObject?) {
        print("alertAcceptAction")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertButton2Action(data: AnyObject?){
        print("alertCancelAction")
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
        switch indexPath.row {
        case 2:
            let alert = SimpleAlertViewController(width: Const.Width, height: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, button1Text: Const.Button1Txt)
            alert.delegate = self
            presentViewController(alert, animated:true, completion:nil)
            
        case 5:
            let alert = SimpleAlertViewController(width: Const.Width, height: Const.Height, titleText: Const.TitleText, mainText: Const.MainText, button1Text: Const.Button1Txt, button2Text: Const.Button2Txt, topImg: Const.Img1, bootomImg: Const.Img2, textFieldPlaceholder: Const.TextFieldPlaceholder)
            alert.delegate = self
            presentViewController(alert, animated:true, completion:nil)
            
        default:
            let alert = SimpleAlertViewController(width: Const.Width, height: Const.Height, titleText: Const.TitleText, mainText: Const.MainText)
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

