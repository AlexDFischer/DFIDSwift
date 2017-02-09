# DFIDSwift
## How to use DFIDSwift
First, make sure Cocoa Pods is installed. You may want to run `pod repo update` because this pod is so new. Create your project in XCode. Run `pod init` in the project directory. In the Podfile that was created, put the following:

    platform :ios, '8.0'

    source 'https://github.com/CocoaPods/Specs.git'

    use_frameworks!

    target 'YOUR_PROJECT_NAME_HERE’ do
        pod 'DFIDSwift', '~> 0.1.3'
    end
    
Now do the command `pod install` in the project directory. This should install DFIDSwift in the current XCode project. Make sure to follow the warning that pod tells you to "Please close any current Xcode sessions and use `YOUR_PROJECT_NAME_HERE.xcworkspace` for this project from now on."

If you're using Objective-C, select 'Later' when it asks you to convert. Instead, you need to change a build setting: click on 'Pods' in the leftmost panel, go to Build Settings, and search for the build setting swift_version. Change the property 'Use Legacy Swift Language Version' to 'No'.

In order to allow the app to check for installed apps: edit the info.plist file in project directory. Add the following after the first `<dict>` line:

    <key>LSApplicationQueriesSchemes</key>
	<array>
		<string>fb</string>
		<string>twitter</string>
		<string>comgooglemaps</string>
		<string>pcast</string>
		<string>mgc</string>
		<string>youtube</string>
		<string>googlechrome</string>
		<string>googledrive</string>
		<string>googlevoice</string>
		<string>ohttp</string>
		<string>firefox</string>
	</array>

To see if it worked, `import DFIDSwift` in some file (or `@import DFIDSwift;` in Objective-C) and try `NSLog("the raw string is: " + DFID.dfid());` (or `NSLog(@"the raw string is: %@\n", [DFID dfid]);` in Objective-C).
