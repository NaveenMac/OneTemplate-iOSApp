//
//  TemplateLookup.swift
//  OneTemplate
//
//  Created by Naveen Chauhan on 16/11/20.
//  Copyright © 2020 OneTemplate. All rights reserved.
//

import Foundation
import UIKit


class TemplateLookup{
    let context:UIViewController?
    public var count:Int
    let ZIP_FILENAME:String = "mtemplates.zip"
    let TEMPLATE_VERSION = "1.0.0"
    let PROFILE_TEMPLATE_VERSION = "1.3.0"
    
    init(context:UIViewController) {
        self.context = context
        self.count = 0
        
    }
    
    func generateHybridModel(){
        let folderName = ZIP_FILENAME.split(separator: ".")
        self.deleteFileOrDir(path: self.getTemplateRootPath(), fname: String(folderName[0]))
        self.copyZipFile(destPath:self.getTemplateRootPath(), filename: ZIP_FILENAME)
        
        let libraryPath = self.getTemplateRootPath()
        let libraryUrl = URL(fileURLWithPath: libraryPath)
        
        var destURL:URL? = nil
        destURL = libraryUrl.appendingPathComponent("\(ZIP_FILENAME)")
        var destPath = destURL?.deletingLastPathComponent()
        destPath?.appendPathComponent(String(folderName[0]))
        unpackZIP(sourceURL: destURL! , destinationURL: destPath!)
        self.deleteFileOrDir(path: self.getTemplateRootPath(), fname: ZIP_FILENAME)
        UserDefaultHelper.isTemplateStored = true
        UserDefaultHelper.isTemplateForceUpdate = false
        UserDefaultHelper.templateVersionStored = TEMPLATE_VERSION
        UserDefaultHelper.profileTemplateVersionStored = PROFILE_TEMPLATE_VERSION
    }
    
    func checkAndUpdateHybridModel(){
        var shouldUpdateProfile = false
        let storedTemplateVersion = UserDefaultHelper.templateVersionStored
        if storedTemplateVersion.compare(TEMPLATE_VERSION,options:.numeric ) == .orderedAscending {
            UserDefaultHelper.isTemplateForceUpdate = true
        }else{
            let storedProfileTemplateVersion = UserDefaultHelper.profileTemplateVersionStored
            if storedProfileTemplateVersion.compare(PROFILE_TEMPLATE_VERSION,options: .numeric) != .orderedSame {
                shouldUpdateProfile = true
            }
        }
        
        
        if (UserDefaultHelper.isTemplateForceUpdate) {
            self.generateHybridModel()
            UserDefaultHelper.templateVersionStored = TEMPLATE_VERSION
        }
        
        if shouldUpdateProfile {
            UpdateSubTemplate(ttype: .PROFILE)
            UserDefaultHelper.profileTemplateVersionStored = PROFILE_TEMPLATE_VERSION
        }
        
    }
    
    func UpdateSubTemplate(ttype:TemplateType){
        
        let zipFileName = "\(ttype.rawValue).zip"
        self.deleteFileOrDir(path: "\(self.getMSubTemplatePath())", fname: ttype.rawValue)
        self.copyZipFile(destPath:"\(self.getMSubTemplatePath())", filename: zipFileName )
        
        let libraryPath = "\(self.getMSubTemplatePath())"
        let libraryUrl = URL(fileURLWithPath: libraryPath)
        
        var destURL:URL? = nil
        destURL = libraryUrl.appendingPathComponent("\(zipFileName)")
        var destPath = destURL?.deletingLastPathComponent()
        destPath?.appendPathComponent(ttype.rawValue)
        unpackZIP(sourceURL: destURL! , destinationURL: destPath!)
        self.deleteFileOrDir(path: "\(self.getMSubTemplatePath())", fname: zipFileName)
        UserDefaultHelper.isTemplateStored = true
        
    }
    
    func sendRequest(context:UIViewController, ttype:TemplateType, tatype:TemplateApiType, params:String){
        
        if(context .isKind(of: ProfileTemplateController.self)){
            if let profileController = self.context as? ProfileTemplateController {
                profileController.showActivityIndicator(show: true)
            }
        }
        
        
        
        var url:URL? = nil
        var doUpdateJSON = false
        var jsonObject:[String: Any]? = nil
        if !params.isEmpty {
            if let paramData = params.data(using: .utf8) {
                do{
                    jsonObject = try JSONSerialization.jsonObject(with: paramData, options: []) as? [String: Any]
                    switch tatype {
                    case .ADD_NOMINEE, .UPDATE_NOMINEE, .DELETE_NOMINEE: break
                        // Some Action
                    default:
                        print("NA")
                    }
                   
                }catch{
                    print(error.localizedDescription)
                }
                
                
            }
            
        }
        
        //var requestType:ApiTypes = .userProfile
        
        switch tatype {
        case .GET_PROFILE:
            //requestType = .userProfile
            
            break
        case .UPDATE_PROFILE:
            //requestType = .updateProfile
            break
        case .GET_NOMINEE:
            //requestType = .getNominee
            
            break;
        case .SEND_OTP:
            //requestType = .sendOTP
           
            break;
        case .VALIDATE_OTP:
             
            if let dict = jsonObject {
                if(dict["type"] as! String=="nominee"){
                    //requestType = .validateProfileOTP
                }else{
                    //requestType = .updateMobileOTP
                }
            }
            
            
            break;
        case .ADD_NOMINEE:
            //requestType = .addNominee
            break;
        case .UPDATE_NOMINEE:
            //requestType = .updateNominee
            break
        case .DELETE_NOMINEE: break
            //requestType = .deleteNominee
        default:
            //requestType = .userProfile
        print("NA")
        }
        
        
        /// Add Network Call here according to request type annd handle acction according to tatyp and request type
        
        
        
    }
    
    
    
    
    // Callback Metthods
    func otpValidationSuccess(json:String){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.otpValidationSuccess(params: json)
        }
        
        
    }
    
    func showOTPBBox(json:String){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.showOTPBox(params: json)
        }
    }
    
    func editPersonalData(json:String){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.editPersonalData(params: json)
        }
    }
    
    func editNomineeData(json:String){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.editNomineeData(params: json)
           
        }
    }
    
    func deleteNomineeData(json:String){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.deleteNomineeData(params: json)
        }
    }
    
    func refreshProfile(){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.refreshProfile()
        }
    }
    
    func refreshNominee(){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.refreshNominee()
        }
    }
    
    func reloadDataOnWeb(){
        if let profileController = self.context as? ProfileTemplateController {
            profileController.reloadWeb()
        }
    }
    
    func goBack(context:UIViewController){
        if(context .isKind(of: ProfileTemplateController.self)){
            let profile:ProfileTemplateController = context as! ProfileTemplateController
            profile.goBack()
        }
    }
    func reloadWeb(context:UIViewController){
        if(context .isKind(of: ProfileTemplateController.self)) {
            let controller:ProfileTemplateController = context as! ProfileTemplateController
            controller.doReloadWeb = true
        }
    }
    
    
    
}



