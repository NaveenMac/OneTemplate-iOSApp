//
//  TemplateConstants.swift
//  OneTemplate
//
//  Created by Naveen Chauhan on 31/12/20.
//  Copyright © 2020 OneTemplate. All rights reserved.
//

import Foundation
import UIKit
import ZIPFoundation

//Template File Manager Methods

extension TemplateLookup{
    
    func updateJSONFile(context:UIViewController, ttype:TemplateType, tatype:TemplateApiType, contents:String){
        var fileName = ""
        var dataObjectName = ""
        var jsPrefix = ""
        var jsSuffix = ""
        switch tatype {
        case .UPDATE_PROFILE, .GET_PROFILE,.UPDATE_DEMO_USER:
            fileName = "profile.js"
            dataObjectName = TemplateLookup.TemplateJSDataObject.personalDetailObject.rawValue
            jsPrefix = "var \(dataObjectName) ="
            break
        
        case .ADD_NOMINEE, .UPDATE_NOMINEE,.GET_NOMINEE,.DELETE_NOMINEE:
            fileName = "nominee.js"
            dataObjectName = TemplateLookup.TemplateJSDataObject.nomineeDetailObject.rawValue
            jsPrefix = "var \(dataObjectName) = ["
            jsSuffix = "]"
        default:
            print("NA")
        }
        
        var jsonContent = contents.replacingOccurrences(of: "[", with: "")
        jsonContent = contents.replacingOccurrences(of: "]", with: "")
        let filePath = self.getMTemplateDataPath(ttype: ttype).appending(fileName)
        self.deleteFileOrDir(path: self.getMTemplateDataPath(ttype: ttype), fname: fileName)
        do{
            let fileContent = "\(jsPrefix)\(jsonContent)\(jsSuffix)"
           try fileContent.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
            
        }catch{
            print(error.localizedDescription)
        }
        
        if(tatype == TemplateApiType.GET_PROFILE || tatype == TemplateApiType.GET_NOMINEE) {
            if(context .isKind(of: ProfileTemplateController.self)){
                let profile:ProfileTemplateController = context as! ProfileTemplateController
                DispatchQueue.main.async {
                    profile.reloadWeb()
                }
               
                
            }
        }
        
        switch tatype {
            case .UPDATE_PROFILE,.GET_PROFILE:
                if let contentData = contents.data(using: .utf8) {
                    do{
                        if let jsonObject = try JSONSerialization.jsonObject(with: contentData, options: []) as? [String: Any] {
                                // UPDATE DATA HERE
                        }
                        
                    }catch{
                        print(error.localizedDescription)
                    }
                    
                    
                }
            default:
                print("NA")
        }
        
    }
    
    
    func readLocalFile(dirPath:String, fileName:String) -> String?{
        let filePath = "\(dirPath)\(fileName)"
        var fileContent:String?
        do{
            if fileExists(filePath: filePath){
                fileContent = try String(contentsOf: URL(fileURLWithPath: filePath))
            }
            
        }catch{
            print(error.localizedDescription)
            fileContent = nil
        }
        return fileContent
    }
    
    func fileExists(filePath:String)->Bool{
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: filePath)
    }
    
    func deleteFileOrDir(path:String, fname:String){
        let filePath = "\(path)\(fname)"
        let fileManager = FileManager.default
        do{
            if fileManager.fileExists(atPath: filePath){
                try fileManager.removeItem(atPath: filePath)
            }
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
   
  
     
}

//Template Path Methods
extension TemplateLookup{
    func documentDirectory() -> String {
       // let filemgr = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       // return filemgr.absoluteString
          let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
          return documentDirectory[0]
        
        
      }
     
   func libraryDirectory() -> String {
             let documentDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory,
                                                                         .userDomainMask,
                                                                         true)
             return documentDirectory[0]
         }
    
    func getTemplateRootPath()->String{
        return   "\(self.libraryDirectory())/"
    }
    
    func getMTemplatePath()->String{
        return   "\(self.getTemplateRootPath())mtemplates/"
    }
    
    func getMSubTemplatePath()->String{
        return   "\(self.getTemplateRootPath())mtemplates/templates/"
    }
    
    func getMSubTemplatePath(ttype:TemplateType)->String{
        return   "\(self.getMTemplatePath())templates/\(ttype.rawValue)/"
    }
    
    func getMTemplateDataPath()->String{
        return   "\(self.getMTemplatePath())data/"
    }
    
    func getMTemplateDataPath(ttype:TemplateType) ->String{
        return   "\(self.getMTemplateDataPath())\(ttype.rawValue)/"
    }
    
    func getMTemplateCommonPath(ttype:TemplateType)->String{
        return "\(self.getMSubTemplatePath(ttype: ttype))common/";
    }
    
    func getMTemplateDataJSPath(ttype:TemplateType, tatype:TemplateApiType) -> String?{
        let fileName:String?
        switch tatype {
        case .GET_PROFILE, .UPDATE_PROFILE:
             fileName = "profile.js"
            break
        case .GET_NOMINEE, .UPDATE_NOMINEE, .ADD_NOMINEE:
             fileName = "nominee.js"
            break
            
        default:
            fileName = nil
        }
        
        guard let file = fileName else {
            return nil
        }
        
        return "\(self.getMTemplateDataPath(ttype: ttype))\(file)"
        
    }
}
// Class Constants
extension TemplateLookup{
    enum ServiceType:String {
        case personal = "personal"
        case nominee = "nominee"
    }

    enum TemplateApiType{
        case GET_PROFILE
        case UPDATE_PROFILE
        case SEND_OTP
        case UPDATE_OTP
        case VALIDATE_OTP
        case GET_NOMINEE
        case ADD_NOMINEE
        case UPDATE_NOMINEE
        case DELETE_NOMINEE
        case INVALID
        case UPDATE_DEMO_USER
    }

    enum TemplateType:String{
        case PROFILE = "profile"
        case DASHBOARD = "dashboard"
    }

    public enum TemplateJSDataObject:String{
        case personalDetailObject = "personalDetailObject"
        case nomineeDetailObject = "nomineeDetailObject"
    }
}


//Template Zipping Methods
extension TemplateLookup{
    func unpackZIP(sourceURL:URL, destinationURL:URL){
        
        let fileManager = FileManager()
        
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
         
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
         
        } catch {
           
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }
    
    func copyZipFile(destPath:String, filename:String){
        
        let libraryUrl = URL(fileURLWithPath: destPath)
        
        var destURL:URL? = nil
        destURL = libraryUrl.appendingPathComponent("\(filename)")
        let arr = filename.split(separator: ".")
        guard let sourceURL = Bundle.main.url(forResource: String(arr[0]), withExtension: String(arr[1]))
            else {
                print("Source File not found.")
                return
        }
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(at: sourceURL, to: destURL!)
            } catch {
                print("Unable to copy file")
            }
        
        
    }
}
