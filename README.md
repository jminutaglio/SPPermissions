# SPPermissions

<img align="left" src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Readme/Preview - 5.0.jpg" width="470"/>

### About
SPPermissions is an API to ask for user permissions using Swift. The API provides for three UI options (list, dialog & native). The UI/UX is in an **Apple style** and supports iPad, dark mode & tvOS. Also you can check the state permissions using the API.

Visit my store for iOS developers:

[![xcode-shop.com](https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Buttons/xcode-shop.svg)](https://xcode-shop.com)

If you like the project, do not forget to `put star ★` and follow me on GitHub:

[![https://github.com/ivanvorobei](https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Buttons/follow-me-on-github.svg)](https://github.com/ivanvorobei)

To help on this project, see the [Сooperation](#сooperation) section or our [chat](https://t.me/sppermissions).

## 5.x Migration - FYI

I have migrated `SPPermissions` to a new `5.0` vesion. If you find any bugs or need the old functionality - please, create an issue or write me. If you want install or stay on the old version (4.1.4), add this to your Podfile:

```ruby
pod 'SPPermissions', '4.1.4'
```

I recomended that you install the new version and create an issue if you have any. I generally respond and resolve all issues within 24-48 hours.

## Navigate

- [Requirements](#requirements)
- [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Swift Package Manager](#swift-package-manager)
    - [Carthage](#carthage)
    - [Manually](#manually)
- [Usage](#usage)
    - [Dialog](#dialog)
    - [List](#list)
    - [Native](#native)
- [Permissions](#permissions)
- [DataSource & Delegate](#datasource--delegate)
- [Good Practices](#good-practices)
- [Keys in Info.plist](#keys-in-infoplist)
    - [Localization](#localization-keys)
- [Сooperation](#сooperation)
- [License](#license)

## Requirements

Swift `4.2` & `5.0`. Ready for use on iOS 11+

## Installation

### CocoaPods:

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate `SPPermissions` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SPPermissions/Notification'
```

Due to Apple's new policy regarding permission access you need to specifically define what kind of permissions you want to access using subspecs. For example if you want to access `Camera`, `Location` & `Microphone` you define the following:

```ruby
pod 'SPPermissions/Camera'
pod 'SPPermissions/Location'
pod 'SPPermissions/Microphone'
```

<details><summary>Available subspecs</summary>
<p>

```ruby
pod 'SPPermissions/Camera'
```
```ruby
pod 'SPPermissions/Contacts'
```
```ruby
pod 'SPPermissions/Calendar'
```
```ruby
pod 'SPPermissions/PhotoLibrary'
```
```ruby
pod 'SPPermissions/Notification'
```
```ruby
pod 'SPPermissions/Microphone'
```
```ruby
pod 'SPPermissions/Reminders'
```
```ruby
pod 'SPPermissions/SpeechRecognizer'
```
```ruby
pod 'SPPermissions/Location'
```
```ruby
pod 'SPPermissions/Motion'
```
```ruby
pod 'SPPermissions/MediaLibrary'
```

</p>
</details>

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate `SPPermissions` into your Xcode project using Xcode 11, specify it in `File > Swift Packages > Add`:

```ogdl
https://github.com/ivanvorobei/SPPermissions
```

After integrate need add configuration. See example [SPPermissionsConfiguration.xcconfig](https://github.com/ivanvorobei/SPPermissions/blob/master/Source/Supporting%20Files/SPPermissionsConfiguration.xcconfig) file or example project. If you don't know how add configuration file, see this [short video](https://youtu.be/1kR5HGVhJfk).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate `SPPermissions` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ivanvorobei/SPPermissions"
```

By default available all permissions. You can provide custom build flags _before_ building the dynamic framework to only compile
with permissions you request. Open file [SPPermissionsConfiguration.xcconfig](https://github.com/ivanvorobei/SPPermissions/blob/master/Source/Supporting%20Files/SPPermissionsConfiguration.xcconfig) in `Source/SPPermissions/Supporting Files`, comment unusable permissions and rebuild:

```ruby
carthage build
```

### Manually

If you prefer not to use any of dependency managers, you can integrate `SPPermissions` into your project manually. Put `Source/SPPermissions` folder in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

After it need add configuration. See example [SPPermissionsConfiguration.xcconfig](https://github.com/ivanvorobei/SPPermissions/blob/master/Source/SPPermissions/Supporting%20Files/SPPermissionsConfiguration.xcconfig) file or example project. If you don't know how add configuration file, see this [short video](https://youtu.be/1kR5HGVhJfk).

## Usage

This project had separate modules for the display UI options. The interfaces are: `Dialog`, `List` and `Native`. Each interface has delegates and a datasource. If you want see an example app, open `SPPermissions.xcodeproj` and choose the `Example` target. 

### Dialog

This is a Modal alert, which was used in the previous version (<5.x). I recomend the use of this alert style when your requested permissions are less than three. Usage will be:

```swift
let controller = SPPermissions.dialog([.camera, .photoLibrary])

// Ovveride texts in controller
controller.titleText = "Title Text"
controller.headerText = "Header Text"
controller.footerText = "Footer Text"

// Set `DataSource` or `Delegate` if need. 
// By default using project texts and icons.
controller.dataSource = self
controller.delegate = self

// Always use this method for present
controller.present(on: self)
```

### List

Native `UITableViewController` with support for the iPad. Use it with more than two permissions. An example of how it is used:

```swift
let controller = SPPermissions.list([.calendar, .camera, .contacts])

// Ovveride texts in controller
controller.titleText = "Title Text"
controller.headerText = "Header Text"
controller.footerText = "Footer Text"

// Set `DataSource` or `Delegate` if need. 
// By default using project texts and icons.
controller.dataSource = self
controller.delegate = self

// Always use this method for present
controller.present(on: self)
```

### Native

Request permissions with native alerts. You can request many permissions at once:

```swift
let controller = SPPermissions.native([.calendar, .camera, .contacts])

// Set `Delegate` if need. 
// Datasource never call, ignore it.
controller.delegate = self

// Always use this method for request. 
// You can pass any controller, this request becouse need implement base protocol.
controller.present(on: self)
```

## Permissions

<p float="left">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Camera.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Photos.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Notifications.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Locations.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Microphone.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Calendar.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Contacts.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Reminders.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Motion.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Media.svg" width="105">
    <img src="https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Permissions/Speech.svg" width="105">
</p>

To check the state of any permission, call enum `SPPermission`: 

```swift
let state = SPPermission.calendar.isAuthorized
```

Also available is the func `isDenied`. This returns false if the permission has not been requested before.

## DataSource & Delegate

You have one method to pass data for each permission. If you return `nil`, SPPermissions will use the default parameters.

```swift
func data(for permission: SPPermission) -> SPPermissionData? {
    return nil
}
```
If you don't want show the alert pop-up if a permission is denied, set `showAlertOpenSettingsWhenPermissionDenied` to false: 

```swift
let notificationData = SPPermissionData(name: "Notification", description: "Remind about new orders for your account.", image: nil, allowTitle: "Allow", allowedTitle: "Allowed")
notificationData.showAlertOpenSettingsWhenPermissionDenied = false
```

If you want show this alert, you need to configure the texts strings:

```swift
notificationData.alertOpenSettingsDeniedPermissionTitle = "Notifiaction denied"
notificationData.alertOpenSettingsDeniedPermissionDescription = "Please, go to Settings and allow permission."
notificationData.alertOpenSettingsDeniedPermissionButtonTitle = "Settings"
notificationData.alertOpenSettingsDeniedPermissionCancelTitle = "Cancel"
```

In the delegate you can implement these three methods: 

```swift
func didAllow(permission: SPPermission) {}
func didDenied(permission: SPPermission) {}
func didHide() {}
```

## Good Practices

I recommend that you show the user all of the permission options, even if some of them are already allowed. But if you want to request only non-allowed permissions, use this code:

```swift
let controller = SPPermissions.list([.notification, .reminders].filter { !$0.isAuthorized } )
controller.present(on: self)
```

A good way to check for the need to show a dialog: check that all permissions are currently authorized by the user:

```swift
let permissions = [.notification, .reminders].filter { !$0.isAuthorized }
if permissions.isEmpty {
    // No need show dialog
} else {
    // Show dialog
}
```

If you are requesting location access, you can show both `.locationWhenInUse` & `.locationAlwaysAndWhenInUse`. If user had already allowed `always` mode, they can change to `when in use` mode:

```swift
let controller = SPPermissions.dialog([.locationWhenInUse, .locationAlwaysAndWhenInUse])
controller.present(on: self)
```

## Keys in Info.plist

You need to add some keys to the `Info.plist` file with descriptions. List of keys:

- NSCameraUsageDescription
- NSContactsUsageDescription
- NSCalendarsUsageDescription
- NSMicrophoneUsageDescription
- NSAppleMusicUsageDescription
- NSSpeechRecognitionUsageDescription
- NSMotionUsageDescription
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription (iOS 10 and earlier)

Do not use the description as the name of the key.

### Localization keys

If you use xliff localization export, keys will be create automatically. If you prefer do the localization file manually, you need to create `InfoPlist.strings`, select languages in the right side menu and add keys as keys in plist-file. See:

```
"NSCameraUsageDescription" = "Here description of usage camera";
```

## Сooperation

The use of this project is completely free! If you can make a contribution, it will help with the project's ongoing development. Here is list of tasks and what needs to be done:

- Add docs in source files. Add a description of public methods and parameters. 
- Subtitles for this [video](https://youtu.be/1kR5HGVhJfk) in any of your native languages, where I tell you how to connect a configuration file.
- Help me translate my app [Debts - Spending tracker](https://itunes.apple.com/app/id1446635818) for other languages. 
- Add icon for the tv os example target.

## Design of previous version

I developed `SPPermissions` in an 'Apple-way'. To accomplish this, I checked 30 apps to get UI-elements for this project. I then took screenshoots and re-drew it in Sketch. For example, the project's `Allow` button is similar to the `Get` button in the AppStore. Check [timelapse](https://youtu.be/1mDdX7fQRv4) to see how I designed the `4.0` version of  `SPPermissions`:

[![Timelaps on YouTube](https://github.com/ivanvorobei/SPPermissions/blob/master/Assets/Readme/YouTube.jpg)](https://youtu.be/1mDdX7fQRv4)

## License

`SPPermissions` is released under the MIT license. Check `LICENSE` for details.
