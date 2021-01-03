![ServiceContainerKit](https://raw.githubusercontent.com/ProVir/ServiceContainerKit/master/ServiceContainerKitLogo.png) 

[![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ProVir/ServiceContainerKit)
[![Platform](https://cocoapod-badges.herokuapp.com/p/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![License](https://cocoapod-badges.herokuapp.com/l/ServiceContainerKit/badge.png)](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE)

  Kit to create your own IoC Container or ServiceLocator. Also includes a ServiceInjects as an option. Support Objective-C in readOnly regime. 
  
  High percentage of unit test coverage **(~ 90%)**.
  
  **P.S.**: We recommend that you download and study the `Example` project, which is made as one of the examples of using the 
  
#
  
      *Dependency Inversion Principle (DIP from SOLI**D**)* allows you to create classes as independent as possible between each other. But developing the services using Dependency Injection, you are faced with the difficulty - how and where to set up services and communications, and how to provide these services to instances that are created during the application process, usually a presentation layer.

      One way to solve this problem is to use *Dependency Injection Container* frameworks that create services for the dependencies and settings that you specify, and also if necessary, injected them in the right parts of the application. The use of such side-by-side frameworks draws certain dependencies throughout the architecture of the application and provides its functionality with certain limitations, which are discussed by the nuances of the programming language, platforms, and as a payment for their universality.

      You can create your own container for a specific project, taking into account its specific features and architecture. One simple way to create your own container is to use a structure with a set of pre-configured services or their factories. Better yet, use a wrapper over services (`ServiceProvider`), which hides the way to create a service - for earlier or as needed, as well as its dependencies and the settings used. 

      To inject dependencies on the presentation layer, you can use 'ServiceInject`, which only requires you to make and register your container with services created according to simple defined rules.

#

      *Dependency Inversion Principle (DIP из SOLI**D**)* позволяет создавать классы максимально независимыми между собой. Но разрабатывая сервисы используя DIP вы сталкиваетесь с трудностью - как и где настроить сервисы и связи, а также как предоставить эти сервисы экземплярам, которые создаются в процессе работы приложения, как правило это слой представления. 

      Один из способов решить эту проблему - это использование фреймворков *Dependency Injection Container*, которые создают сервисы по указываемым вами зависисмостям и настройкам, а также внедряют их по необходимости в нужные части приложения. Использование подобных стороних фреймворков тянет за собой наличие определенных зависимостей во всей архитекртуре приложения и предоставляют свой функционал с определенными ограничениями, которые обсуловлены нюансами языка программирования, платформы и как плата за их универсальность.  

      Вы можете создать свой собственный контейнер для конкретного проекта с учетом его специфики и архитектуры. Один из простых способов создать свой контейнер - это использовать структуру с набором созданных и настроенных заранее сервисов либо их фабрик. А еще лучше - использовать обертку над сервисами (`ServiceProvider`), скрывающую способ создания сервиса - за ранее или по необходимости, а также его зависимости и используемые настройки.

      Для внедрения зависимостей на слое представления можно использовать `ServiceInject`, который только требует создать и зарегистрировать свой контейнер с сервисами, созданный по простым определенным правилам. 

#

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Migration from 2.0 to 3.0](#migration-from-20-to-30)
- [Installation](#installation)
- [Usage ServiceFactory (English / Русский)](#usage-servicefactory)
- [Usage IoC Container and ServiceProvider (English / Русский)](#usage-ioc-container-and-serviceprovider)
- [Author](#author)
- [License](#license)


## Features

`ServiceProvider` and `ServiceParamsProvider` - wrapper for the service to hide the details of its making:
- [x] Type services: single, lazy, weak and many instance. 
- [x] Support remaked singleton services. 
- [x] Create from service factories, existing instance or closure factory. 
- [x] Throws errors when make service, result get service as optional or with detail error. 
- [x] Service factories with parameters for many instance services. 
- [x] Support thread safe providers.
- [x] Get service from provider in Objective-C code. 
- [x] Support custom logger.


## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 11.0 and above
- Swift 5.2 and above


## Communication

- If you **need help**, go to my telegram [@ViR_RuS](https://t.me/ViR_RuS)
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Migration from 2.0 to 3.0

In version 3.0, the `ServiceLocator` and `ServiceEasyLocator` was deleted. 
Example updated versions you can founded in `Tester` target - manually copy to your project. 

A lot of refactoring was done on ServiceProviders, as a result of which many types and methods were renamed. 
We recommend that you read the documentation before migrating to the new version.
Also learn the new example app from target `Example`.


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.9.0+ is required to build ServiceContainerKit 3.0.0+.

To integrate ServiceContainerKit (without Injects) into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target '<Your Target Name>' do
  pod 'ServiceContainerKit', '~> 3.0'
end
```

If you also need to use ServiceInject and EntityInject, then use:
```ruby
target '<Your Target Name>' do
  pod 'ServiceContainerKit/Injects', '~> 3.0'
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
github "ProVir/ServiceContainerKit" ~> 3.0
```

Run `carthage update` to build the framework and drag the built `ServiceContainerKit.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding ServiceContainerKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/ProVir/ServiceContainerKit", .upToNextMajor(from: "3.0.0"))
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ServiceContainerKit into your project manually.

Copy files from directory `Sources` in your project. 


---


**Note:** To use the library, remember to include it in each file: `import ServiceContainerKit`.

The project has a less abstract example of using the library, which can be downloaded separately.

## Usage ServiceFactory

  To use `ServiceProvider` or` ServiceParamsProvider` it is recommended for each service to use a factory (struct or class) implementing the protocol `ServiceFactory` or` ServiceParamsFactory`. 
  A factory without parameters (`ServiceFactory`) can provide a service of three types (`factoryType`):
  - `atOne`: service in a single instance is created immediately during the creation of the ServiceProvider instance, the factory itself is no longer needed;
  - `lazy`: service in a single copy is not created immediately, but only at the first get service. The factory exists only until the instant of creation of the service instance and is deleted after its creation;
  - `many`: the service is created each time a new one for each get service to receive it. It can also be used to implement its lazy initialization logic or some other - not necessarily every get service should return a new instance.
  
  A factory with parameters (`ServiceParamsFactory`) works only as a service of the` many` type. To implement `atOne` or` lazy` types, you need to use internal variables (the factory itself is a class) and provide them based on input parameters.
  
  The service creation function can return an error that will prevent the creation of the service. While get service, you can process this error. If the error was returned for a factory of the type `atOne` - then the provider will always return this error when trying to get the service. If the error was returned for a factory of the `lazy` type, the provider will attempt to create a service each time it is get service again until the service is created.

#

  Для использования `ServiceProvider` или `ServiceParamsProvider` рекомендуется для каждого сервиса использовать фабрику (struct или class) реализующую протокол `ServiceFactory` или `ServiceParamsFactory`. 
  Фабрика без параметров (`ServiceFactory`) может предоставлять сервис трех типов (`factoryType`):
  - `atOne`: сервис в единственном экземпляре создается сразу во время создания экземпляра ServiceProvider, сама фабрика больше не нужна;
  - `lazy`: сервис в единственном экземпляре создается не сразу, а только при первом требовании. Фабрика существует только до момента создания экземпляра сервиса и удалется после его создания;
  - `many`: сервис создается каждый раз новый при каждом запросе на его получение. Также может использоваться для реализации своей логики lazy инициализации или какой-либо другой - не обязательно каждый запрос должен возвращать новый экземпляр.

  Фабрика с параметрами (`ServiceParamsFactory`) работает только как сервис типа `many`. Для реализации типов `atOne` или `lazy` вам потребуется использовать внутренние переменные (сама фабрика при этом является классом) и предоставлять их на основе входных параметров. 

  Функция создания сервиса может вернуть ошибку, которая предотвратит создание сервиса. Во время получения сервиса можно обработать эту ошибку. Если ошибка была возвращена для фабрики типа `atOne` - то провайдер всегда будет возвращать эту ошибку при попытки получить сервис. Если ошибка была возвращена для фабрики типа `lazy` - провайдер будет производить попытки создать сервис каждый раз при его запросе заново пока сервис не будет создан. 

#### An examples service factorys:
```swift
struct SingletonServiceFactory: ServiceFactory {
    let factoryType: ServiceFactoryType = .atOne

    func createService() throws -> SingletonService {
        return SingletonService()
    }
}
```

```swift
struct LazyServiceFactory: ServiceFactory {
    let factoryType: ServiceFactoryType = .lazy

    func createService() throws -> LazyService {
        return LazyService()
    }
}
```
```swift
class FirstServiceFactory: ServiceFactory {
    let singletonServiceProvider: ServiceProvider<SingletonService>
    var count: Int
    
    init(singletonServiceProvider: ServiceProvider<SingletonService>) {
        self.singletonServiceProvider = singletonServiceProvider
        self.count = 0
    }

    let factoryType: ServiceFactoryType = .many
    func createService() throws -> FirstService {
        count += 1
        defer {
            print("Service created number: \(count)")
        }
        
        return FirstService(singletonService: try singletonServiceProvider.tryService())
    }
}
```
```swift
struct SecondServiceFactory: ServiceParamsFactory {
    let lazyServiceProvider: ServiceProvider<LazyService>
    let firstServiceProvider: ServiceProvider<FirstService>

    func createService(params: SecondServiceParams?) throws -> SecondService {
        let instance = SecondService(lazyService: try lazyServiceProvider.tryService(),
                                     firstService: try firstServiceProvider.tryService())
        instance.number = params?.number ?? -1
        return instance
    }
}
```

## Usage IoC Container and ServiceProvider

### IoC Container

 It is assumed that the IoC Container contains service providers (`ServiceProvider` and` ServiceParamsProvider`). Also the container can contain important singleton services without the provider, if they are an important system component of the application (for example UserService - work with the user and his authorization status in the application, because the authorization status is the same for the entire application session at a time). 

  Предполагается что IoC Container содержит провайдеры сервисов (`ServiceProvider` и `ServiceParamsProvider`). Также контейнер может содержать важные сервисы синглетоны без провайдера, если они являются важным системным компонентом приложения (к примеру UserService - работа с пользователем и его статусом авторизации в приложении, т.к. статус авторизации един для всей сессии приложения в один момент времени). 

#### An example IoC Container:
```swift
struct ServiceContainer {
    let userService: UserService

    let singletonServiceProvider: ServiceProvider<SingletonService>
    let lazyServiceProvider: ServiceProvider<LazyService>

    let firstServiceProvider: ServiceProvider<FirstService>
    let secondServiceProvider: ServiceParamsProvider<SecondService, SecondServiceParams?>

    let sharedFirstService: FirstService
    let secondServiceNumber0Provider: ServiceProvider<SecondService>
}

//MARK: Setup
extension ServiceContainer {
    static func createDefault() -> ServiceContainer {
        let userService = UserServiceFactory().createService()
    
        let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
        let lazyServiceProvider = ServiceProvider(factory: LazyServiceFactory())

        let firstServiceProvider = FirstServiceFactory(singletonServiceProvider: singletonServiceProvider).serviceProvider()
        let secondServiceProvider = SecondServiceFactory(lazyServiceProvider: lazyServiceProvider,
                                                         firstServiceProvider: firstServiceProvider).serviceProvider()

        let sharedFirstService: FirstService = firstServiceProvider.getService()!
        let secondServiceNumber0Provider = secondServiceProvider.convert(params: .init(number: 0))

        return ServiceContainer(userService: userService,
                                singletonServiceProvider: singletonServiceProvider,
                                lazyServiceProvider: lazyServiceProvider,
                                firstServiceProvider: firstServiceProvider,
                                secondServiceProvider: secondServiceProvider,
                                sharedFirstService: sharedFirstService,
                                secondServiceNumber0Provider: secondServiceNumber0Provider)
    }
}
```

In order not to depend on the library in the whole project, you can make the providers private and provide a public interface for making the service.

Для того чтобы не зависить от библиотеки во всем проекте, можно сделать провайдеры приватными и предоставить публичный интерфейс для получения самого сервиса.

#### An example private ServiceProviders:
```swift
struct ServiceContainer {
    private let firstServiceProvider: ServiceProvider<FirstService>
    private let secondServiceProvider: ServiceParamsProvider<SecondService, SecondServiceParams?>

    let userService: UserService

    func makeFirstService() throws -> FirstService {
        return try firstServiceProvider.tryService()
    }

    func makeSecondService(params: SecondServiceParams?) throws -> SecondService {
        return try secondServiceProvider.tryService(params: params)
    }
}
```

### Service[Params]Provider

You can create `ServiceProvider` in several ways:
- using a regular factory: by calling function `ServiceFactory().serviceProvider()` (recommended) or through constructors `ServiceProvider(factory:)` and `ServiceProvider(tryFactory:)`;
- using factory with parameters: by calling function `ServiceFactory().serviceProvider(params:)` (recommended) or through constructor `ServiceProvider(factory:params:)`;
- using provider with parameters: `ServiceParamsProvider.convert(params:)`;
- using an already created service, passing it to the constructor: `ServiceProvider()`, factory equivalent of `atOne` type;
- using closures in lazy mode or generating a new instance each time: `ServiceProvider(lazy: { })` и `ServiceProvider(manyFactory: { })`, factory equivalent of  `lazy` and `many` types.

You can create `ServiceParamsProvider` only by using a factory with parameters (`ServiceParamsFactory`): `ServiceParamsProvider(factory:)`.

Examples of creating `Service[Params]Provider` are shown in the example above with the IoC Container.

To get the service it is enough to call the function `Service[Params]Provider.getService()` which returns the service as an option, `nil` will be returned in case of a service error. You can also use `Service[Params]Provider.tryService()` - then the service is returned not as an option and can generate an error why the service was not getted (unlike `getService()`, which simply returns `nil`).

#

Создать `ServiceProvider` можно несколькими способами:
- используя обычную фабрику: через вызов `ServiceFactory().serviceProvider()` (рекомендуется) или через конструкторы `ServiceProvider(factory:)` и `ServiceProvider(tryFactory:)`;
- используя фабрику с параметрами: через вызов `ServiceFactory().serviceProvider(params:)` (рекомендуется) или через конструктор `ServiceProvider(factory:,params:)`;
- используя провайдер с параметрами: `ServiceParamsProvider.convert(params:)`;
- используя уже созданный сервис, передав его в конструктор: `ServiceProvider()`, эквивалент фабрики типа `atOne`;
- используя кложуры в lazy режиме или генерируя каждый раз новый экземпляр: `ServiceProvider(lazy: { })` и `ServiceProvider(manyFactory: { })`, эквиваленты фабрик типов `lazy` и `many`.

Создать `ServiceParamsProvider` можно только используя фабрику с параметрами (`ServiceParamsFactory`): `ServiceParamsProvider(factory:)`.

Примеры создания `Service[Params]Provider` приведены в примере выше с IoC Container.


Для получения сервиса достаточно вызвать функцию `Service[Params]Provider.getService()` которая возвращает сервис как опционал, `nil` будет возвращен в случае ошибки получения сервиса. Также можно использовать `Service[Params]Provider.tryService()` - тогда сервис возвращается не как опционал и может генерировать ошибку почему сервис не был получен (в отличие от `getService()`, который просто вернет `nil`). 


#### An example use ServiceProvider:
```swift
let firstService = serviceContainer.firstServiceProvider.getService()!

let secondService: SecondService
do {
    secondService = serviceContainer.firstServiceProvider.tryService()
} catch {
    fatalError("Error get secondService: \(error)")
}
```

### Support Objective-C

Creating and configuring the container is only available for swift code, but for objective-c, you can provide a special wrapper to getting the services.

`ServiceProviderObjC` (in Objective-C is visible as `ServiceProvider`) and `ServiceParamsProviderObjC` (in Objective-C is visible as `ServiceParamsProvider`) can be created from any `Service[Params]Provider`, passing it (swift option) to the constructor in the swift code.


You can get the service through selectors `[ServiceProvider getService]` and `[ServiceProvider getServiceAndReturnError:]`, also `[ServiceParamsProvider getServiceWithParams:]` and `[ServiceProvider getServiceWithParams:andReturnError:]`.

#### An example use ServiceProvider:
```objc
FirstService* firstService = [self.serviceContainer.firstServiceProvider getService];

NSError* error = nil;
SecondService* secondService = [self.serviceContainer.secondServiceProvider getServiceAndReturnError:&error];

ThirdService* thirdService = [self.serviceContainer.thirdServiceProvider getServiceWithParams:@"test"];
```


## Author

[**ViR (Короткий Виталий)**](http://provir.ru)

[Telegram: @ViR_RuS](https://t.me/ViR_RuS)


## License

ServiceContainerKit is released under the MIT license. [See LICENSE](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE) for details.

