# Debugger-iOS

Database Debugger is a handy tool for iOS applications. When enabled, developers have access to database of application in realtime. No need of exporting the database.

# Caution
This project is very unstable and not handled large data and security. That is on the way. Consider it as sample or tutorial.
# Set-up

### In Mac
1. Clone the project
2. Double click the *Debugger.xcodeproj* and run it, you can see a mac application called Debugger window.
3. Stay calm wait for the application to run

### In application
1. Add the *Debugger_lib.xcodeproj* inside *Swift-lib* into working project or build and take framework and link to your project.

#### For swift project

> Inside AppDelegate.swift
```
import ...
import Debugger_lib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ...
        CommunicationManager().initializeSession()
        }
     ...
     }
```

#### For Objective-C project

In this case you have to add some Bridging-header files to interoperability of swift and obj-c

1. Create *ProjectName-**Bridging-header.h*** file
2. Find *Objective-C Bridging Header* key under *Build Settings menu* and add the value as *ProjectName/ProjectName-Bridging-header.h* 

> Inside ProjectName-Bridging-header.h
```
@import Debugger_lib;
```

> Inside AppDelegate.swift

```
....

@import Debugger_lib;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CommunicationManager *channel = [CommunicationManager new];
    [channel initializeSession];
    return YES;   
}

@end
```

## Sample Images

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-13%20at%204.12.19%20PM.png)

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-13%20at%204.13.00%20PM.png)

## Thank you

[SQLite](https://www.sqlite.org/index.html)

[Peertalk](https://github.com/rsms/peertalk)

[SwiftSQLite](https://github.com/chrismsimpson/SwiftSQLite)

## Copyright
Do whatever you want. For an extra assurance I have added MIT Licence.

## Contact
Contact me via godwinjoseph.k@gmail.com or www.linkedin.com/in/godwin-joseph, if you have any questions or improvements.
