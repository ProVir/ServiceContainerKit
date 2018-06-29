# ServiceContainerKit

[![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ProVir/ServiceContainerKit)
[![Platform](https://cocoapod-badges.herokuapp.com/p/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![License](https://cocoapod-badges.herokuapp.com/l/ServiceContainerKit/badge.png)](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE)

Kit to create your own IoC Container or ServiceLocator. Also includes a ServiceLocator as an option. Require Swift 4 and above, support Objective-C in readOnly regime. 

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage (English / Русский)](#usage-english--%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)
- [Simple File Storage](#simple-file-storage)
- [Mock Engine](#mock-engine)
- [Author](#author)
- [License](#license)


## Features

`ServiceProvider` and `ServiceParamsProvider` - wrapper for the service to hide the details of its creation:
- [x] Support type services: single, lazy and many instance. 
- [x] Create from service factories, existing instance or closure factory with support lazy create. 
- [x] Support throws errors when create service, result get service as optional or with detail error. 
- [x] Support service factories with parameters for many instance services. 
- [x] Support get service from provider in Objective-C code. 

`ServiceLocator` (optional) - ready as container to use easy: 
- [x] Add services as provider, service factories, existing instance or closure factory with support lazy create. 
- [x] Support use as singleton - static variable `share` and static functions. 
- [x] ReadOnly regime - after setted assert when edit list services in ServiceLocator. 
- [x] Support throws errors when create service, result get service as optional or with detail error. 
- [x] Support services with parameters for create instance.
- [x] Support get services in Objective-C code. 


## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.0 and above
- Swift 4.0 and above


## Communication

- If you **need help**, go to [provir.ru](http://provir.ru)
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build ServiceContainerKit 1.0.0+.

To integrate ServiceContainerKit (without ServiceLocator) into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
pod 'ServiceContainerKit', '~> 1.0'
end
```
If you also need to use ServiceLocator, then use:
```ruby
target '<Your Target Name>' do
pod 'ServiceContainerKit/ServiceLocator', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ServiceContainerKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ProVir/ServiceContainerKit" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `ServiceContainerKit.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but ServiceContainerKit does support its use on supported platforms. 

Once you have your Swift package set up, adding ServiceContainerKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
.Package(url: "https://github.com/ProVir/ServiceContainerKit.git", majorVersion: 1)
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ServiceContainerKit into your project manually.

Copy files from directory `Source` in your project. 


---

## Usage (English / Русский)





## Author

[**ViR (Короткий Виталий)**](http://provir.ru)


## License

ServiceContainerKit is released under the MIT license. [See LICENSE](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE) for details.

