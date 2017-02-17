import UIKit
import CoreTelephony
import CryptoSwift

@objc
open class DFID: NSObject {
    
    static let DFID_VERSION: String = "dfid_v8_alpha";
    
    static func systemName() -> String {
        var size: Int = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        var name: [CChar] = [CChar](repeating: 0, count: size);
        sysctlbyname("hw.machine", &name, &size, nil, 0);
        return String(describing: name);
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
        let apps: [String] = ["tel", "sms", "fb", "twitter", "ibooks", "comgooglemaps", "pcast", "mgc", "youtube", "googlechrome", "googledrive", "googlevoice", "firefox"];
        var installed: [String] = [];
        for app in apps {
            let url = NSURL(string: (app + "://test"))!;
            if (UIApplication.shared.canOpenURL(url as URL)) {
                installed.append(app);
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
    
    public static func buildRawString() -> String {
        var components: [String] = [String]();
        components.append(DFID_VERSION);
        components.append(systemName());
        components.append(String(diskSpace()));
        components.append(canOpenApps());
        components.append(hasCydia() ? "hasCydia" : "does not have Cydia");
        components.append(languageList());
        components.append(carrierInfo());
        return components.joined(separator: ";");
    }
    
    public static func dfid() -> String {
        let rawString: String = buildRawString();
        let hash = rawString.sha512();
        return hash;
    }
    
}
