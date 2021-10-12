//
//  UserDefaultHelper.swift
//  OneTemplate

import Foundation
import UIKit


enum UserDefaultsKey: String {
   
   case isTemplateStored = "isTemplateStored"
   case isTemplateForceUpdate = "isTemplateForceUpdate"
   case templateVersionStored = "templateVersionStored"
    case profileTemplateVersionStored = "profileTemplateVersionStored"

   
}

final class UserDefaultHelper {
    
    static var templateVersionStored :String {
       set{
           _set(value: newValue, key: .templateVersionStored)
       }get{
          return _get(valueForKay: .templateVersionStored) as? String ?? "1.0.0"
       }
    }
    
    static var profileTemplateVersionStored :String {
       set{
           _set(value: newValue, key: .profileTemplateVersionStored)
       }get{
          return _get(valueForKay: .profileTemplateVersionStored) as? String ?? "1.0.0"
       }
    }
    
    static var isTemplateStored :Bool {
       set{
           _set(value: newValue, key: .isTemplateStored)
       }get{
          return _get(valueForKay: .isTemplateStored) as? Bool ?? false
       }
    }
    
    static var isTemplateForceUpdate :Bool {
       set{
           _set(value: newValue, key: .isTemplateForceUpdate)
       }get{
          return _get(valueForKay: .isTemplateForceUpdate) as? Bool ?? false
       }
    }
    
    static var isProfileTemplateForceUpdate :Bool {
       set{
           _set(value: newValue, key: .isTemplateForceUpdate)
       }get{
          return _get(valueForKay: .isTemplateForceUpdate) as? Bool ?? false
       }
    }
    
   

    private static func _set(value: Any?, key: UserDefaultsKey) {
        UserDefaults(suiteName: "com.onetemplate.iOSApp")!.set(value, forKey: key.rawValue)
    
    }
    
    private static func _get(valueForKay key:UserDefaultsKey)-> Any? {
        return UserDefaults(suiteName: "com.onetemplate.iosApp")!.value(forKey: key.rawValue)
    }

    

}

