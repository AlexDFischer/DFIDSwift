# DFIDSwift
## How to use DFIDSwift
First, make sure Cocoa Pods is installed. You may want to run `pod repo update` because this pod is so new. Create your project in XCode. Run `pod init` in the project directory. In the Podfile that was created, put the following:

    platform :ios, '8.0'

    source 'https://github.com/CocoaPods/Specs.git'

    use_frameworks!

    target 'YOUR_PROJECT_NAME_HERE’ do
        pod 'DFIDSwift', '~> 0.1.1'
    end
    
Now do the command `pod install` in the project directory. This should install DFIDSwift in the current XCode project. Make sure to follow the warning that pod tells you to "Please close any current Xcode sessions and use `YOUR_PROJECT_NAME_HERE.xcworkspace` for this project from now on."

To see if it worked, `import DFIDSwift` in some file (or `@import DFIDSwift;` in Objective-C) and try `NSLog("the raw string is: " + DFID.dfid());` (or `NSLog(@"the raw string is: %@\n", [DFID dfid]);` in Objective-C).
