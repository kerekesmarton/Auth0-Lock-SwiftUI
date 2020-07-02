# Auth0-Lock-SwiftUI

[![CI Status](https://img.shields.io/travis/Marton Kerekes/Auth0-Lock-SwiftUI.svg?style=flat)](https://travis-ci.org/Marton Kerekes/Auth0-Lock-SwiftUI)
[![Version](https://img.shields.io/cocoapods/v/Auth0-Lock-SwiftUI.svg?style=flat)](https://cocoapods.org/pods/Auth0-Lock-SwiftUI)
[![License](https://img.shields.io/cocoapods/l/Auth0-Lock-SwiftUI.svg?style=flat)](https://cocoapods.org/pods/Auth0-Lock-SwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/Auth0-Lock-SwiftUI.svg?style=flat)](https://cocoapods.org/pods/Auth0-Lock-SwiftUI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Since we're using SwiftUI, supported version is `iOS13`.

## Installation

### Pod
Auth0-Lock-SwiftUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Auth0-Lock-SwiftUI' //This has as transitive dependencies `Lock`, which depends on `Auth0`.
```

### Use the code directly:

Copy `AuthView` and `SessionPublisher`, then use them as per the example provided in `SessionView`. Note, there are a few helpers in `View.swift`

Then include Lock as a pod.
```ruby
pod 'Lock' //This has as transitive dependency on `Auth0`.
```

## Usage

Follow the [guide](https://auth0.com/docs/quickstart/native/ios-swift#before-you-start) to install required values to Auth0.plist
Without these, the app crashes when Auth0 framework checks for these values.

```
<!-- Auth0.plist -->

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>ClientId</key>
  <string>YOUR_CLIENT_ID</string>
  <key>Domain</key>
  <string>YOUR_DOMAIN</string>
</dict>
</plist>
```

The `SessionPublisher` is an `ObservableObject` that publishes a viewModel with it's states:

```
enum SessionViewModel {
    case hasSession(user: UserInfo)
    case loading
    case guest
    case error(String)
}
```

Use this object in your view where you want to present your Auth0 login:

`@ObservedObject var session = SessionPublisher()`

For example:

```
var body: some View {
    switch session.viewModel {
    case .loading:
        return makeLoadingView()
    case .error(let error):
        return VStack {
            makeErrorView(error)
            
            Button(action: {
                self.showingLogin.toggle()
            }) {
                Text("Please try log in again")
            }.sheet(isPresented: $showingLogin) {
                AuthView(session: self.session)
            }.padding()
        }.anyView
    case .guest:
        return Button(action: {
            self.showingLogin.toggle()
        }) {
            Text("Please log in")
        }.sheet(isPresented: $showingLogin) {
            AuthView(session: self.session)
        }.padding().anyView
    case .hasSession(user: let userName):
        return VStack {
            Text("Welcome \(userName)!")
            Button.init("Logout") {
                self.session.logout()
            }
        }.anyView
    }
}
```

## Author

Marton Kerekes, kerekes.j.marton@gmail.com

## License

Auth0-Lock-SwiftUI is available under the MIT license. See the LICENSE file for more info.
