# Debugger-iOS

Database Debugger is a handy tool for iOS applications. When enabled, developers have access to database of application in realtime. No need of exporting the database.

# Caution
This project is very unstable and not handled large data and security. That is on the way. Consider it as sample or tutorial.
# Set-up

### In Mac
Find the latest version of macApp from Releases folder ([Debugger_v1.3](https://github.com/godwinjk/Debugger-iOS/blob/master/Release/Debugger_v1.3.zip))

**OR**

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
        DebuggerIos.initWithDefault() // If database is in documents folder
        
        // OR
        
        let dbPath = getDatabasePath() // If database is other than documents folder
        DebuggerIos.initWithPath(dbPaths: dbPaths)
        
        }
     ...
     }
```

#### For Objective-C project

In this case you have to add some Bridging-header files to interoperability of swift and obj-c

1. Create *ProjectName-**Bridging-header.h*** file
2. Find *Objective-C Bridging Header* key under *Build Settings menu/Swift Compiler* and add the value as *ProjectName/ProjectName-Bridging-header.h* 
3. If you don't see that menu, just create a swift file, XCode automatically promt to create a bridging header and will add to the settings menu (easy).
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
    [DebuggerIos initWithDefault];
    
    // OR 
    
     NSArray *dbPaths = [self getDatabasePath];
    [DebuggerIos initWithPathWithDbPaths:dbPaths];
    ....   
}

@end
```

## Sample Images

**Application Listing**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-24%20at%2012.51.26%20PM.png)

**Database Listing**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-13%20at%204.12.19%20PM.png)

**Table listing and details**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-13%20at%204.13.00%20PM.png)

**Suggestion**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-24%20at%2012.43.09%20PM.png)

**Query results (Histories are on the way)**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-24%20at%2012.44.15%20PM.png)

**Data modification (modified results are on the way)**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-24%20at%2012.45.21%20PM.png)

**Error handling**

![Alt text](https://github.com/godwinjk/Debugger-iOS/blob/master/Images/Screenshot%202019-06-24%20at%2012.46.48%20PM.png)

## Thank you

[SQLite](https://www.sqlite.org/index.html)

[Peertalk](https://github.com/rsms/peertalk)

[SwiftSQLite](https://github.com/chrismsimpson/SwiftSQLite)

## Copyright
Do whatever you want. For an extra assurance I have added MIT Licence.

## Contact
Contact me via godwinjoseph.k@gmail.com or www.linkedin.com/in/godwin-joseph, if you have any questions or improvements.
Or be a contributor :D
