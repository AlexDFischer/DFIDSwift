import UIKit
import CoreTelephony
import MessageUI

public class DFID: NSObject {
    
    static let DFID_VERSION: String = "dfid_v8_alpha";
    
    static func systemType() -> String {
        var size: Int = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        var name: [CChar] = [CChar](repeating: 0, count: size);
        sysctlbyname("hw.machine", &name, &size, nil, 0);
        return String(cString: name);
    }
    
    static func deviceName() -> String {
        return UIDevice.current.name;
    }
    
    static func diskSpace() -> Int64 {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dictionary = try? FileManager.default.attributesOfFileSystem(forPath: paths.last!) {
            if let freeSize = dictionary[FileAttributeKey.systemSize] as? NSNumber {
                return freeSize.int64Value;
            }
        }
        return 0;
    }
    
    static func canOpenApps() -> String {
        let apps: [String] = ["tel", "sms", "fb", "twitter", "ibooks", "comgooglemaps", "pcast", "mgc", "youtube", "googlechrome", "googledrive", "googlevoice", "ohttp", "firefox"];
        var installed: [String] = [];
        for app in apps {
            let url = NSURL(string: (app + "://test"))!;
            if (UIApplication.shared.canOpenURL(url as URL)) {
                installed.append("T");
            } else {
                installed.append("F");
            }
        }
        return installed.joined(separator: ",");
    }
    
    static func hasCydia() -> Bool {
        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app");
    }
    
    static func languageList() -> String {
        return NSLocale.preferredLanguages.joined(separator: ",");
    }
    
    static func carrierInfo() -> String {
        let networkInfo = CTTelephonyNetworkInfo();
        var carrierInfo: [String] = [String]();
        let provider = networkInfo.subscriberCellularProvider;
        if (provider != nil) {
            carrierInfo.append(provider!.carrierName == nil ? "no carrier name" : provider!.carrierName!);
            carrierInfo.append(provider!.mobileCountryCode == nil ? "no MCC" : provider!.mobileCountryCode!);
            carrierInfo.append(provider!.mobileNetworkCode == nil ? "no MNC" : provider!.mobileNetworkCode!);
            carrierInfo.append(String(provider!.allowsVOIP));
        } else {
            carrierInfo.append("no subscriber cellular provider");
        }
        return carrierInfo.joined(separator: ",");
    }
    
    static func messageConfigs() -> String {
        var configs: [String] = [String]();
        configs.append(MFMailComposeViewController.canSendMail() ? "T" : "F");
        configs.append(MFMessageComposeViewController.canSendText() ? "T" : "F");
        configs.append(MFMessageComposeViewController.canSendSubject() ? "T" : "F");
        configs.append(MFMessageComposeViewController.canSendAttachments() ? "T" : "F");
        return configs.joined(separator: ",");
    }
    
    public static func buildRawString() -> String {
        var components: [String] = [String]();
        components.append(DFID_VERSION);
        components.append(systemType());
        components.append(deviceName());
        components.append(String(diskSpace()));
        components.append(canOpenApps());
        components.append(hasCydia() ? "hasCydia" : "does not have Cydia");
        components.append(languageList());
        components.append(carrierInfo());
        components.append(messageConfigs());
        return components.joined(separator: ";");
    }
    
    public static func dfid() -> String {
        let rawString: String = buildRawString();
        // doesn't hash it yet because importing common crypto library is ungodly complicated in swift
        return rawString;
    }

}
