import UIKit
import CoreTelephony
import CryptoSwift // for hashing
import CoreLocation
import LocalAuthentication
import Speech // for siri info
import PassKit // for ApplePay info

@objc
open class DFID: NSObject {
    
    static let DFID_VERSION: String = "dfid_v8_alpha";
    
    static func localGroundTruth() -> String {
        // determine if we have generated a ground truth and return it if so
        let defaults = UserDefaults.standard;
        let key: String = "DFIDSwift_local_ground_truth";
        if let groundTruth: String = defaults.string(forKey: key) {
            return groundTruth;
        } else {
            // if we haven't previously generated one, generate a new ground truth
            srandom(UInt32(NSDate().timeIntervalSince1970));
            let random = String(arc4random(), radix: 16) + String(arc4random(), radix: 16);
            defaults.setValue(random, forKey: key);
            return random;
        }
    }
    
    static func vendorID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString;
    }
    
    static func batteryLevel() -> String {
        return String(UIDevice.current.batteryLevel);
    }
    
    static func batteryState() -> String {
        switch (UIDevice.current.batteryState) {
        case UIDeviceBatteryState.charging:
            return "charging";
        case UIDeviceBatteryState.full:
            return "full";
        case UIDeviceBatteryState.unknown:
            return "unknown";
        case UIDeviceBatteryState.unplugged:
            return "unplugged";
        }
    }
    
    static func deviceOS() -> String {
        return UIDevice.current.systemName;
    }
    
    static func deviceOSVersion() -> String {
        return UIDevice.current.systemVersion;
    }
    
    static func deviceName() -> String {
        return UIDevice.current.name;
    }
    
    static func deviceModel() -> String {
        return UIDevice.current.model;
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
    
    static func fontSize() -> Float {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body);
        return fontDescriptor.fontAttributes["NSFontSizeAttribute"]! as! Float;
    }
    
    static func fontBold() -> Bool {
        let systemFont: UIFont = UIFont.systemFont(ofSize: 12);
        return systemFont.fontName.range(of: "bold") != nil;
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
    
    static func locServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled();
    }
    
    static func touchIDEnabled() -> Bool {
        let authenticationContext = LAContext();
        return authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil);
    }
    
    static func siriEnabled() -> Bool {
        if #available(iOS 10.0, *) {
            return SFSpeechRecognizer.init() != nil
        } else {
            return false;
        };
    }
    
    static func applePayInfo() -> String {
        if #available(iOS 10.0, *) {
            let request: PKPaymentRequest = PKPaymentRequest.init();
            var result: String = "";
            for paymentNetwork: PKPaymentNetwork in PKPaymentRequest.availableNetworks() {
                result += paymentNetwork.rawValue + ",";
            }
            result += request.billingContact != nil ? request.billingContact!.description : "no billing contact";
            return result;
        } else {
            return "apply pay not available in this iOS version";
        };
    }
    
    static func dateTimeFormat() -> String {
        let date: Date = Date.init(timeIntervalSince1970: 0);
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full;
        dateFormatter.timeStyle = .full;
        return dateFormatter.string(from: date);
    }
    
    static func localeIdentifier() -> String {
        return Locale.current.identifier;
    }
    
    static func temperatureUnit() -> String {
        if let temperatureUnit = UserDefaults.standard.string(forKey: "AppleTemperatureUnit") {
            return temperatureUnit;
        } else {
            return "TemperatureUnitUnavailable";
        }
    }
    
    static func keyboards() -> String {
        // NOTE: I found these keys in UserDefaults by printing UserDefaults.standard.dictionaryRepresentation()
        // TODO: search through the above output to find more stuff to identify a device with
        
        if let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") {
            return (keyboards as! [String]).joined(separator: ",");
        } else
        {
            if let keyboards = UserDefaults.standard.object(forKey: "ApplePasscodeKeyboards") {
                return (keyboards as! [String]).joined(separator: ",");
            } else {
                return "NoKeyboardsListed";
            }
        }
    }
    
    public static func deviceIdentifier() -> String {
        return jsonStringFromDictionary(dict: rawData()).sha512();
    }
    
    /**
     * All of the data that is used to compute the device identifier
     */
    public static func rawData() -> [String: String]  {
        UIDevice.current.isBatteryMonitoringEnabled = true;
        
        var dict = [String: String]();
        dict.updateValue(deviceOS(),                               forKey: "device_os");
        dict.updateValue(deviceOSVersion(),                        forKey: "device_os_version");
        dict.updateValue(deviceModel(),                            forKey: "device_model");
        dict.updateValue(deviceName(),                             forKey: "device_name");
        dict.updateValue(String(diskSpace()),                      forKey: "disk_space");
        dict.updateValue(carrierInfo(),                            forKey: "carrier_info");
        dict.updateValue(languageList(),                           forKey: "language_list");
        dict.updateValue(String(describing: hasCydia()),           forKey: "has_cydia");
        dict.updateValue(String(describing: fontSize()),           forKey: "font_size");
        dict.updateValue(String(describing: fontBold()),           forKey: "font_bold");
        dict.updateValue(String(describing: locServicesEnabled()), forKey: "loc_services_enabled");
        dict.updateValue(String(describing: touchIDEnabled()),     forKey: "touch_id_enabled");
        dict.updateValue(String(describing: siriEnabled()),        forKey: "siri_enabled");
        dict.updateValue(applePayInfo(),                           forKey: "apple_pay_info");
        dict.updateValue(dateTimeFormat(),                         forKey: "date_time_format");
        dict.updateValue(localeIdentifier(),                       forKey: "locale_identifier");
        dict.updateValue(temperatureUnit(),                        forKey: "temperature_unit");
        dict.updateValue(keyboards(),                              forKey: "keyboards");
        dict.updateValue(canOpenApps(),                            forKey: "can_open_apps");
        
        return dict;
    }
    
    /**
     * Appends extra data onto the dictionary that will be sent, such as
     * the device identifier, battery info, and time of measurement.
     */
    public static func extraData() -> [String: String] {
        let oldDict: [String: String] = rawData();
        var dict: [String: String] = oldDict;
        dict.updateValue(jsonStringFromDictionary(dict: dict).sha512(), forKey: "device_identifier");
        
        let formatter = DateFormatter();
        formatter.dateFormat = "ccc, dd MMM yyyy HH:mm:ss zzz";
        formatter.timeZone = TimeZone.init(abbreviation: "GMT");
        dict.updateValue(formatter.string(from: Date()),                forKey: "measured_at");
        dict.updateValue(batteryLevel(),                                forKey: "battery_level");
        dict.updateValue(batteryState(),                                forKey: "battery_state");
        dict.updateValue(vendorID(),                                    forKey: "vendor_id");
        dict.updateValue(localGroundTruth(),                            forKey: "local_ground_truth");
        return dict;
    }
    
    public static func jsonStringFromDictionary(dict: [String: String]) -> String {
        var result: String = "{\n";
        for key in dict.keys {
            if (result.characters.count > 2) {
                result += ",\n";
            }
            result += "\t\"" + key + "\": \"" + dict[key]! + "\"";
        }
        result += "\n}\n";
        return result;
    }
    
    public static func sendData(apiKey: String) -> Void {
        print("starting sendData function");
        var request = URLRequest(url: URL(string: "https://qf4c68odc3.execute-api.us-east-1.amazonaws.com/prod/storeInfo")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        let postString = jsonStringFromDictionary(dict: extraData());
        request.httpBody = postString.data(using: .utf8)
        print("request body is: " + postString);
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("handler function called");
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
}
