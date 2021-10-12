//
//  ProfileWebViewController.swift
//  OneTemplate
//
//  Created by Naveen Chauhan on 08/10/20.
//  Copyright © 2020 OneTemplate. All rights reserved.
//

import UIKit
import WebKit
import Material


class ProfileTemplateController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    
    var templateLookup:TemplateLookup? = nil
    var doReloadWeb: Bool = true;
    
    var datePicker: UIDatePicker!
    var datePickerConstraints = [NSLayoutConstraint]()
    var blurEffectView: UIView!
    lazy var activityIndicator:UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        return activityIndicator
    }()
    lazy var datePickerContainer:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
//    lazy var  datePicker:UIDatePicker = {
//        let dateFormatter = DateFormatter()
//
//        let datePicker = UIDatePicker()
//        datePicker.date = Date()
//        datePicker.locale = .current
//        datePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
//        if #available(iOS 13.4, *) {
//            datePicker.preferredDatePickerStyle = .wheels
//        }
//        datePicker.datePickerMode = .date
//        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
//        return datePicker
//    }()
    
    
    
    lazy var webView : WKWebView = {
        let contentController = WKUserContentController()
        
        contentController.add(self, name: "sendOTP")
        contentController.add(self, name: "verifyOTP")
        contentController.add(self, name: "updateProfileData")
        contentController.add(self, name: "updateNomineeData")
        contentController.add(self, name: "refreshSection")
        contentController.add(self, name: "confirmDeleteNominee")
        contentController.add(self, name: "writeUserPersonalData")
        contentController.add(self, name: "writeNomineeData")
        contentController.add(self, name: "exitTemplate")
        contentController.add(self, name: "reloadWeb")
        contentController.add(self, name: "showToast")
        contentController.add(self, name: "showDatePicker")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let w = WKWebView(frame: self.view.bounds, configuration: config)
        w.navigationDelegate = self
        w.scrollView.delegate = self
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        w.configuration.preferences = preferences
        w.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        w.allowsBackForwardNavigationGestures = true
        
        return w
    }()
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return nil
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
         scrollView.setZoomScale(1.0, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let methodStart = NSDate()
       // self.webView.frame = self.view.frame
        templateLookup = TemplateLookup(context: self)
        let b = UIBarButtonItem(image:  Icon.cm.arrowBack,style: .plain, target: self, action: #selector(onBackPressed))
        let lockerLogo = UIBarButtonItem(image:UIImage(named: "top.png") , style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItems = [b,lockerLogo]
        
        
        let templatePath = templateLookup?.getMSubTemplatePath(ttype: .PROFILE)
            let fileManager = FileManager.default
        let indexFilePath = templatePath?.appending("index.html")
        
//        let nativePath = templateLookup?.getMTemplateCommonPath(ttype: .PROFILE).appending("native.json")
//
//        if let jsonData = NSData(contentsOfFile: nativePath, options: .DataReadingMappedIfSafe, error: nil)
//            {
//                if let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
//                {
//                    if let persons : NSArray = jsonResult["version"] as? NSArray
//                    {
//                        // Do stuff
//                    }
//                }
//             }
        if fileManager.fileExists(atPath: indexFilePath!) {
            let tt = templateLookup?.getTemplateRootPath()
            let htmlurl = URL(fileURLWithPath: indexFilePath!)
            let durl = URL(fileURLWithPath: tt!, isDirectory: true)
           
            self.view.layout(self.webView).edges()
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = .gray

            view.addSubview(activityIndicator)
//
            webView.loadFileURL(htmlurl, allowingReadAccessTo: durl)


        }else{
           
        }
      
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //let methodStart = NSDate()
        
        let profileDataPath = templateLookup!.getMTemplateDataJSPath(ttype: .PROFILE, tatype: .GET_PROFILE)
        
        if (!templateLookup!.fileExists(filePath: profileDataPath!)){
            
            let tatype:TemplateLookup.TemplateApiType = .GET_PROFILE
            templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
        }else{
           

        }
        
        let nomineeDataPath = templateLookup!.getMTemplateDataJSPath(ttype: .PROFILE, tatype: .GET_NOMINEE)
       
        
        if (!templateLookup!.fileExists(filePath: nomineeDataPath!)){
            
            let tatype:TemplateLookup.TemplateApiType = .GET_NOMINEE
            templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
        }else{
            let tatype:TemplateLookup.TemplateApiType = .GET_NOMINEE
            templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
        }
        

    }
    
    @objc func onBackPressed(){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("onBackPressed()") { (any, error) in
                        print("Error: \(String(describing: error))")
                        }
        }
        
    }
    
   
    public func showActivityIndicator(show:Bool){
        DispatchQueue.main.async {
            if show {
                self.activityIndicator.startAnimating()
            }else{
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    public func sendRequest(tatype:TemplateLookup.TemplateApiType,jsonObject:Dictionary<String,AnyObject>?){
        if let obj  = jsonObject{
            templateLookup?.count = 0
            templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: obj.description)
        }else{
            templateLookup?.count = 0
            templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
        }
    }
    
    public func reloadWeb(){
        self.webView.reload()
    }
    
    public func showOTPBox(params:String){
        
//        self.webView.evaluateJavaScript("showMobileOTP('\(params)')") { (any, error) in
//            print("Error: \(String(describing: error))")
//            }
        if let data = params.data(using: .utf8)
            {
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("showMobileOTP('\(String(data: data, encoding: .utf8)!)')") { (any, error) in
                    print("Error: \(String(describing: error))")
                    }
            }
            
        }
        
    }
    
    public func editPersonalData(params:String){
        DispatchQueue.main.async {
        self.webView.evaluateJavaScript("editPersonalData('\(params)')") { (any, error) in
            print("Error: \(String(describing: error))")
            }
        }
    }
    
    public func editNomineeData(params:String){
        DispatchQueue.main.async {
           self.writeNomineeData(params: params)
       
            self.webView.evaluateJavaScript("editNomineeData('\(params)')") { (any, error) in
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    public func deleteNomineeData(params:String){
        DispatchQueue.main.async {
        self.webView.evaluateJavaScript("deleteNomineeData('\(params)')") { (any, error) in
            print("Error: \(String(describing: error))")
            }
        }
    }
    
    public func refreshProfile(){
        let tatype:TemplateLookup.TemplateApiType = .GET_PROFILE
        templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
            
    }
    
    public func refreshNominee(){
        let tatype:TemplateLookup.TemplateApiType = .GET_NOMINEE
        templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: "")
            
    }
    
    public func otpValidationSuccess(params:String){
        DispatchQueue.main.async {
        self.webView.evaluateJavaScript("otpSuccess('\(params)')") { (any, error) in
            print("Error: \(String(describing: error))")
            }
        }
    }
    
    public func deleteNominee(obj:[String:AnyObject]){
        let tatype:TemplateLookup.TemplateApiType = .DELETE_NOMINEE
        templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: tatype, params: obj.description)
        self.doReloadWeb = false
        self.refreshNominee()
    }
    
    public func showConfirmationDialogue(obj:[String:String]){
        
    }
    
    public func goBack(){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("onBackPressed()") { (any, error) in
                print("Error: \(String(describing: error))")
                }
        }
        
    }
    
    public func exitTemplate(){
        self.navigationController?.popViewController(animated: true)
    }
    
    public func writeUserPersonalData(params:String){
        templateLookup?.updateJSONFile(context: self, ttype: .PROFILE, tatype: .UPDATE_PROFILE, contents: params)
            
    }
    
    public func writeNomineeData(params:String){
        templateLookup?.updateJSONFile(context: self, ttype: .PROFILE, tatype: .UPDATE_NOMINEE, contents: params)
            
    }
    
    public func showLoading(){
        
    }
    
    public func dismissLoading(){
    
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //let methodStart = NSDate()
        
       
            showActivityIndicator(show: false)

        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           /// let methodStart = NSDate()
            
        }
    
       

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           
        }
    

}

extension ProfileTemplateController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dict = message.body as? Dictionary<String, String>
        
        switch message.name {
        case "sendOTP":
            self.sendMobileOTP(params: dict)
            
            break
        case "verifyOTP":
            self.verifyOTP(params: dict)
            
            break
        case "updateProfileData":
            self.updateProfileData(params: dict)
            break
        case "updateNomineeData":
            self.updateNomineeData(params: dict)
            break
        case "refreshSection":
            self.refreshSection(params: dict)
            break
        case "confirmDeleteNominee":
            self.confirmDeleteNominee(params:dict )
            break
        case "writeUserPersonalData":
            self.writeUserPersonalData(params: dict)
            break
        case "writeNomineeData":
            self.writeNomineeData(params: dict)
            break
        case "exitTemplate":
            self.exitTemplate()
            break
        case "reloadWeb":
            self.reloadWeb()
            break
        case "showDatePicker":
            self.showDatePicker()
            break
        case "showToast":
            if let msg = message.body as? String {
                self.showToast(params: msg)
            }
            break
        default:
            print("NA")
        }
        
    }
    
    @objc func datePicked(){
        for view in datePickerContainer.arrangedSubviews {
            view.removeFromSuperview()
        }
        datePickerConstraints.removeAll()
        blurEffectView.removeFromSuperview()
        datePickerContainer.removeFromSuperview()
    }
   @objc func datePickerValueChanged(_ sender: UIDatePicker){
    let dateFormatter: DateFormatter = DateFormatter()
            
            // Set date format
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            // Apply date format
            let selectedDate: String = dateFormatter.string(from: sender.date)
            DispatchQueue.main.async {
                self.webView.evaluateJavaScript("setDOBDate('\(selectedDate)')") { (any, error) in
                            print("Error: \(String(describing: error))")
                            }
            }
           
    }
    
    func addDatePickerAsSubview(){
        guard let datePicker = datePicker else { return }
        // Give the background Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        centerDatePicker()
        view.bringSubviewToFront(datePicker)
    }
    
    func centerDatePicker() {
        guard let datePicker = datePicker else { return }
        let button = Button()
        button.addTarget(self, action: #selector(datePicked), for: .touchUpInside)
    button.title = "Done"
        
        //self.view.addSubview(datePicker)
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePickerContainer.addArrangedSubview(datePicker)
        datePickerContainer.addArrangedSubview(button)
        
        self.view.addSubview(datePickerContainer)
       
            // Center the Date Picker
            datePickerConstraints.append(datePickerContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor))
            datePickerConstraints.append(datePickerContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor))
            
            NSLayoutConstraint.activate(datePickerConstraints)
        }
    
}


//Callback Methods
extension ProfileTemplateController {
    private func sendMobileOTP(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .SEND_OTP, params: jsonString)
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    private func verifyOTP(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .VALIDATE_OTP, params: jsonString)
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    private func updateProfileData(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .UPDATE_PROFILE, params: jsonString)
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    private func updateNomineeData(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                let requestType = args["request_type"]
                if(requestType?.lowercased() == "u"){
                    self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .UPDATE_NOMINEE, params: jsonString)
                }else{
                    self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .ADD_NOMINEE, params: jsonString)
                }
                
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    
    private func refreshSection(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                let requestType = args["section"]
                if(requestType?.lowercased() == "1"){
                    self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .GET_PROFILE, params: jsonString)
                }else{
                    self.templateLookup?.sendRequest(context: self, ttype: .PROFILE, tatype: .GET_NOMINEE, params: jsonString)
                }
                
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    private func confirmDeleteNominee(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        self.showConfirmationDialogue(obj: args)
        
    }
    
    
    private func writeUserPersonalData(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options:[])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                self.writeUserPersonalData(params: jsonString)
                
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
    private func writeNomineeData(params:Dictionary<String, String>?){
        guard let args = params else{
            return
        }
        
        do{
            let paramData = try JSONSerialization.data(withJSONObject: args, options: [])
            if let jsonString = String(data: paramData, encoding: .utf8) {
                self.writeNomineeData(params: jsonString)
                
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
       
        
    }
    
   
    private func showDatePicker() {
        let dateFormatter = DateFormatter()
        datePicker = UIDatePicker()
        datePicker?.date = Date()
        datePicker?.locale = .current
        datePicker?.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        addDatePickerAsSubview()
    }
    
    private func reloadWeb(params:String){
        self.reloadWeb()
    }
    
    private func showToast(params:String){
        let alert = UIAlertController(title: "title", message: params, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
       
    }
    
    
    
}
