![ServiceContainerKit](https://raw.githubusercontent.com/ProVir/ServiceContainerKit/master/ServiceContainerKitLogo.png) 

[![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ProVir/ServiceContainerKit)
[![Platform](https://cocoapod-badges.herokuapp.com/p/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![License](https://cocoapod-badges.herokuapp.com/l/ServiceContainerKit/badge.png)](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE)

  Kit to create your own ServiceContainer or ServiceLocator (dynamic list services). Also includes a ServiceInjects as an option. Support Objective-C in readOnly regime. 
  
  High percentage of unit test coverage **(~ 90%)**.
  
  **P.S.**: We recommend that you download and study the `Example` project, which is made as one of the usage examples.
  
  - [Introduction](#introduction)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Communication](#communication)
  - [Migration from 2.0 to 3.0](#migration-from-20-to-30)
  - [Installation](#installation)
  - [Usage ServiceFactory (English / Русский)](#usage-servicefactory)
  - [Usage ServiceProvider (English / Русский)](#usage-serviceprovider)
  - [Author](#author)
  - [License](#license)
  
## Introduction
  
      *Dependency Inversion Principle (DIP from SOLI**D**)* allows you to create classes as independent as possible between each other. But developing the services using Dependency Injection, you are faced with the difficulty - how and where to set up services and communications, and how to provide these services to instances that are created during the application process, usually a presentation layer.

      One way to solve this problem is to use *Dependency Injection Container* frameworks that create services for the dependencies and settings that you specify, and also if necessary, injected them in the right parts of the application. The use of such side-by-side frameworks draws certain dependencies throughout the architecture of the application and provides its functionality with certain limitations, which are discussed by the nuances of the programming language, platforms, and as a payment for their universality.

      You can create your own container for a specific project, taking into account its specific features and architecture. One simple way to create your own container is to use a structure with a set of pre-configured services or their factories. Better yet, use a wrapper over services (`ServiceProvider`), which hides the way to create a service - for earlier or as needed, as well as its dependencies and the settings used. 

      To inject dependencies on the presentation layer, you can use 'ServiceInject`, which only requires you to make and register your container with services created according to simple defined rules.

#

      *Dependency Inversion Principle (DIP из SOLI**D**)* позволяет создавать классы максимально независимыми между собой. Но разрабатывая сервисы используя DIP вы сталкиваетесь с трудностью - как и где настроить сервисы и связи, а также как предоставить эти сервисы экземплярам, которые создаются в процессе работы приложения, как правило это слой представления. 

      Один из способов решить эту проблему - это использование фреймворков *Dependency Injection Container*, которые создают сервисы по указываемым вами зависисмостям и настройкам, а также внедряют их по необходимости в нужные части приложения. Использование подобных стороних фреймворков тянет за собой наличие определенных зависимостей во всей архитекртуре приложения и предоставляют свой функционал с определенными ограничениями, которые обсуловлены нюансами языка программирования, платформы и как плата за их универсальность.  

      Вы можете создать свой собственный контейнер для конкретного проекта с учетом его специфики и архитектуры. Один из простых способов создать свой контейнер - это использовать структуру с набором созданных и настроенных заранее сервисов либо их фабрик. А еще лучше - использовать обертку над сервисами (`ServiceProvider`), скрывающую способ создания сервиса - за ранее или по необходимости, а также его зависимости и используемые настройки.

      Для внедрения зависимостей на слое представления можно использовать `ServiceInject`, который только требует создать и зарегистрировать свой контейнер с сервисами, созданный по определенным простым правилам. 

#


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

To integrate ServiceContainerKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target '<Your Target Name>' do
  pod 'ServiceContainerKit', '~> 3.0'
  pod 'ServiceInjects', '~> 3.0'
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

Run `carthage update` to build the framework and drag the built `ServiceContainerKit.framework` and `ServiceInjects.framework`  into your Xcode project.



### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding ServiceContainerKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/ProVir/ServiceContainerKit", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            dependencies: [
                .byName(name: "ServiceContainerKit"), 
                .product(name: "ServiceInjects", package: "ServiceContainerKit")
            ]
        )
    ]
)
```


### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ServiceContainerKit into your project manually.

Copy files from directory `ServiceContainerKit/Sources` and `ServiceInjects/Sources` in your project. 


---


**Note:** To use the library, remember to include it in each file: `import ServiceContainerKit` and  `import ServiceInjects`.

The project has a less abstract example of using the library, which can be downloaded separately.

## Usage ServiceFactory

  To use `ServiceProvider` or` ServiceParamsProvider` it is recommended for each service to use a factory (struct or class) implementing the protocol `ServiceFactory`, `ServiceSessionFactory` or` ServiceParamsFactory`. 
  A factory without parameters (`ServiceFactory`) can provide a service of four types (`factoryType`):
  - `atOne`: service in a single instance is created immediately during the creation of the ServiceProvider instance, the factory itself is no longer needed;
  - `lazy`: service in a single instance is not created immediately, but only at the first get service. The factory exists only until the instant of creation of the service instance and is deleted after its creation;
  - `weak`: service is not created immediately, but only at the first get service. The service exists in a single instance as long as it is used somewhere, then it is deleted and a new one will be created again when a new get request. This type is a cross between `lazy` and `many` and is usually used for performance reasons;
  - `many`: the service is created each time a new one for each get service to receive it. It can also be used to implement its lazy initialization logic or some other - not necessarily every get service should return a new instance.
  
  A factory with parameters (`ServiceParamsFactory`) works only as a service of the` many` type. To implement `atOne` or` lazy` types, you need to use internal variables (the factory itself is a class) and provide them based on input parameters.
  
  The service creation function can return an error that will prevent the creation of the service. While get service, you can process this error. If the error was returned for a factory of the type `atOne` - then the provider will always return this error when trying to get the service. If the error was returned for a factory of the `lazy` type, the provider will attempt to create a service each time it is get service again until the service is created.

#

  Для использования `ServiceProvider` или `ServiceParamsProvider` рекомендуется для каждого сервиса использовать фабрику (struct или class) реализующую протокол `ServiceFactory`, `ServiceSessionFactory` или `ServiceParamsFactory`. 
  Фабрика без параметров (`ServiceFactory`) может предоставлять сервис четырех типов (`factoryType`):
  - `atOne`: сервис в единственном экземпляре создается сразу во время создания экземпляра ServiceProvider, сама фабрика больше не нужна;
  - `lazy`: сервис в единственном экземпляре создается не сразу, а только при первом требовании. Фабрика существует только до момента создания экземпляра сервиса и удалется после его создания;
  - `weak`: сервис создается не сразу, а только при первом требовании. Сервис в единственном экземпляре существует пока где-либо используется, после - удаляется и при новом запросе будет создан заново новый. Этот тип среднее между `lazy` и  `many` и обычно используется ради повышения производительности;
  - `many`: сервис создается каждый раз новый при каждом запросе на его получение. Также может использоваться для реализации своей логики lazy инициализации или какой-либо другой - не обязательно каждый запрос должен возвращать новый экземпляр.

  Фабрика с параметрами (`ServiceParamsFactory`) работает только как сервис типа `many`. Для реализации типов `atOne` или `lazy` вам потребуется использовать внутренние переменные (сама фабрика при этом является классом) и предоставлять их на основе входных параметров. 
  
  Фабрика с возможностью пересоздавать сервисы в единственном экземпляре (`ServiceSessionFactory`) работает на идеи сессий - при сменне текущей сессии на другую все зависимые сервисы пересоздаются. Вместо пересоздавания они могут деактивироваться и активироваться когда сессия станет снова активна.
  Такой тип фабрики не поддерживает работу с `many` типом сервисов - могут быть только синглетоны. Для всех типов сервисов фабрика никогда не удаляется, для типа `atOne` сервис создается или активируется сразу при каждой смене сессии.

  Функция создания сервиса может вернуть ошибку, которая предотвратит создание сервиса. Во время получения сервиса можно обработать эту ошибку. Если ошибка была возвращена для фабрики типа `atOne` - то провайдер всегда будет возвращать эту ошибку при попытки получить сервис. Если ошибка была возвращена для фабрики типа `lazy` - провайдер будет производить попытки создать сервис каждый раз при его запросе заново пока сервис не будет создан. 

#### An examples service factories:
```swift
struct SingletonServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> SingletonService {
        return SingletonServiceImpl()
    }
}
```

```swift
struct LazyServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .lazy
    func makeService() throws -> LazyService {
        return LazyServiceImpl()
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

    let mode: ServiceFactoryMode = .many
    func makeService() throws -> FirstService {
        count += 1
        defer {
            print("Service created number: \(count)")
        }
        return FirstServiceImpl(singletonService: try singletonServiceProvider.getService())
    }
}
```

```swift
struct SecondServiceFactory: ServiceParamsFactory {
    let lazyServiceProvider: ServiceProvider<LazyService>
    let firstServiceProvider: ServiceProvider<FirstService>

    func makeService(params: SecondServiceParams?) throws -> SecondService {
        let instance = SecondService(
            lazyService: try lazyServiceProvider.getService(),
            firstService: try firstServiceProvider.getService()
        )
        instance.number = params?.number ?? -1
        return instance
    }
}
```

## Usage ServiceProvider

### Service Container

 It is assumed that the Container contains service providers (`ServiceProvider` and` ServiceParamsProvider`).
 Also the container can contain important singleton services without the provider, if they are used at the start - for example, in Application Delegate or other system component. As a rule, for such services, it is better to allocate a separate container for use in these cases. An example can be found in `Example/AppDelegate.swift` and `AppDelegateServices`.

  Предполагается что контейнер содержит провайдеры сервисов (`ServiceProvider` и `ServiceParamsProvider`). 
  Также контейнер может содержать важные сервисы синглетоны без провайдера, если они используются на старте - к примеру в Application Delegate или другим системном компоненте. Как правило для таких сервисов лучше выделить отдельный контейнер для использования именно в этих случаях. Пример можно посмотреть в `Example/AppDelegate.swift` и `AppDelegateServices`.

#### An example Container:
```swift
struct Services {
    struct User {
        let userService: ServiceProvider<UserService>
    }
    
    struct Folders {
        let manager: ServiceProvider<NoteFoldersManager>
    }
    
    struct Notes {
        let manager: ServiceParamsProvider<NoteRecordsManager, NoteRecordsManagerParams>
        let editService: ServiceParamsProvider<NoteRecordEditService, NoteRecordEditServiceParams>
    }
    
    let user: User
    let folders: Folders
    let notes: Notes
}

struct AppDelegateServices {
    let userService: UserService
    let pushService: PushService
}

// MARK: Setup
enum ServicesFactory {
    static func makeDefault() -> (Services, AppDelegateServices) {
        let core = ServicesCore.makeDefault()
        
        let user = Services.User.makeDefault(core: core)
        let folders = Services.Folders.makeDefault(core: core, user: user)
        let notes = Services.Notes.makeDefault(core: core, user: user, folders: folders)
        
        let services = Services(
            user: user,
            folders: folders,
            notes: notes
        )
        
        let pushService = PushServiceFactory().makeService()
        let appDelegateService = AppDelegateServices(
            userService: user.userService.getServiceOrFatal(),
            pushService: pushService
        )
        return (services, appDelegateService)
    }
}

extension Services.Notes {
    static func makeDefault(core: ServicesCore, user: Services.User, folders: Services.Folders) -> Self {
        let manager = NoteRecordsManagerFactory(
            apiClient: core.apiClient,
            userService: user.userService
        ).serviceProvider()
        
        let editService = NoteRecordEditServiceFactory(
            apiClient: core.apiClient,
            recordsManager: manager
        ).serviceProvider()
        
        return .init(manager: manager, editService: editService)
    }
}

....
```

In order not to depend on the library in the whole project, you can make the providers private and provide a public interface for making the service.

Для того чтобы не зависеть от библиотеки во всем проекте, можно сделать провайдеры приватными и предоставить публичный интерфейс для получения самого сервиса.

#### An example private ServiceProviders:
```swift
struct ServiceContainer {
    private let firstServiceProvider: ServiceProvider<FirstService>
    private let secondServiceProvider: ServiceParamsProvider<SecondService, SecondServiceParams?>

    private let userService: UserService

    func getFirstService() -> FirstService {
        return firstServiceProvider.getServiceOrFatal()
    }

    func getSecondService(params: SecondServiceParams?) throws -> SecondService {
        return try secondServiceProvider.getService(params: params)
    }
    
    func getUserService() -> UserService {
        return userService
    }
}
```

### Service[Params]Provider

You can create `ServiceProvider` in several ways:
- using a regular factory: by calling function `ServiceFactory().serviceProvider()` (recommended) or through constructors `ServiceProvider(factory:)` and `ServiceProvider(tryFactory:)`;
- using factory with parameters: by calling function `ServiceFactory().serviceProvider(params:)` (recommended) or through constructor `ServiceProvider(factory:params:)`;
- sing a factory with re-maked singletons linked to sessions: by calling function `ServiceFactory().serviceProvider(mediator:)` (recommended) or through constructor `ServiceProvider(factory:mediator:)`.
- using provider with parameters: `ServiceParamsProvider.convert(params:)`;
- using an already created service, passing it to the constructor: `ServiceProvider()`, factory equivalent of `atOne` type;
- using closure with mode setting: `ServiceProvider(mode:) { }`.



You can create `ServiceParamsProvider` by using a factory with parameters (`ServiceParamsFactory`): `ServiceParamsProvider(factory:)` or using closure `ServiceParamsProvider { params in }`.

To get the service it is enough to call the function `try Service[Params]Provider.getService()` which returns the service or error. 
You can also use `Service[Params]Provider.getServiceAsResult()`,  `Service[Params]Provider.getServiceAsOptional()` - then the service is returned as an option (nil in case of an error) or `Service[Params]Provider.getServiceOrFatal()` - in case of an error, there will be a crash with detailed information about the error.
Use `getServiceOrFatal()` instead of  `try! getService()` or `getServiceAsOptional()!`, so that the cause of the crash is not lost and is easily determined.

#

Создать `ServiceProvider` можно несколькими способами:
- используя обычную фабрику: через вызов `ServiceFactory().serviceProvider()` (рекомендуется) или через конструкторы `ServiceProvider(factory:)` и `ServiceProvider(tryFactory:)`;
- используя фабрику с параметрами: через вызов `ServiceFactory().serviceProvider(params:)` (рекомендуется) или через конструктор `ServiceProvider(factory:params:)`;
- используя фабрику с пересоздаваемыми сервисами синглетонами, привязанными к сессиям: через вызов `ServiceFactory().serviceProvider(mediator:)` (рекомендуется) или через конструктор `ServiceProvider(factory:mediator:)`.
- используя провайдер с параметрами: `ServiceParamsProvider.convert(params:)`;
- используя уже созданный сервис, передав его в конструктор: `ServiceProvider()`, эквивалент фабрики типа `atOne`;
- используя кложур с указанием режима: `ServiceProvider(mode:) { }`.

Создать `ServiceParamsProvider` можно используя фабрику с параметрами (`ServiceParamsFactory`) `ServiceParamsProvider(factory:)` или используя кложур  `ServiceParamsProvider { params in }`.

Для получения сервиса достаточно вызвать функцию `try Service[Params]Provider.getService()` которая возвращает сервис или ошибку. 
Также можно использовать `Service[Params]Provider.getServiceAsResult()`,  `Service[Params]Provider.getServiceAsOptional()` - тогда сервис возвращается как опционал (nil в случае ошибки) или `Service[Params]Provider.getServiceOrFatal()` - в случае ошибки будет краш с подробной информацией об ошибке. 
Используйте `getServiceOrFatal()` вместо `try! getService()` или `getServiceAsOptional()!`, чтобы причина краша не потерялась и была легко определима.


#### An example use ServiceProvider:
```swift
let firstService = serviceContainer.firstService.getServiceOrFatal()

let secondService: SecondService
do {
    secondService = try serviceContainer.firstService.getService()
} catch let error as ServiceObtainError {
    fatalError(error.fatalMessage)
} catch {
    fatalError("Error get firstService: \(error)")
}
```

### Service[Params]SafeProvider

In some cases, you may need to get services from different threads. To support multithreading, you can use special thread-safe providers. Their task is to make each service receipt thread-safe by blocking or using synchronously a separate queue for each access to the provider and the factory.
This is usually not required, because the configuration of services at the start of the application and their receipt in the presentation layer occurs in the main thread. But if there are cases when the service is requested not from the main thread - you should use a secure provider. Getting the service from such a provider may be slower than usual.

To create a secure provider, use the `serviceSafeProvider()` or constructor methods.
The default is `NSLock`, but you can choose `DispatchSemaphore` or a separate queue `DispatchQueue`.

`Service[Params]SafeProvider` is a inheritance of regular providers, so the entire standard set of methods is available and you can store and pass such a provider as a regular one. But in addition, there is one method - `getServiceAsResultNotSafe()`, which will ignore any locks and perform the usual non-secure getting of the service.

#

В некоторых случаях может потребоваться получать сервисы из разных потоков. Чтобы поддержать мультипоточность можно использовать специальные потоко-безопасные провайдеры. Их задача - каждое получение сервиса сделать потоко-безопасным, блокируя или используя синхронно отдельную очередь при каждом обращении к првайдеру и фабрике.
Обычно это не требуется, т.к. настройка сервисов при старте приложения и их получения в слое презентации происходит в главном потоке. Но если есть случаи когда сервис запрашивается не из главного потока - следует использовать безопасный провайдер. Получение сервиса у такого провайдера может быть медленнее обычного.

Для создания безпасного провайдера используются методы `serviceSafeProvider()` или конструктор. 
По умолчанию используется `NSLock`, но вы можете выбрать `DispatchSemaphore` или отдельную очередь `DispatchQueue`.

`Service[Params]SafeProvider` является наследником обычных провайдеров, поэтому доступен весь стандартный набор методов и можно хранить и передавать такой провайдер как обычный. Но в дополнение есть один метод - `getServiceAsResultNotSafe()`, который проигнорирует любые блокировки и выполнит обычное не безопасное получение сервиса.


#### An example use ServiceSafeProvider:
```swift
struct ServiceContainer {
    let firstService: ServiceProvider<FirstService>
}

extension ServiceContainer {
    static func makeDefault() -> ServiceContainer {
        let firstService: ServiceSafeProvider<FirstService> = FirstServiceFactory().serviceSafeProvider(safeThread: .lock)
        
        return .init(
            firstService: firstService
        )
    }
}

let service = container.firstService.getServiceAsOptional()
```

### ServiceObtainError

If an error occurs as a result of getting the service, the provider returns `ServiceObtainError` with the original error and detailed information.
The error will contain information about the service in whose factory the error was throwed. Since services are dependent on each other and there is nesting when getting, the error may occur when getting a dependent service, and not when getting the original one - for this purpose, the error contains information about the path to the service with the error.

#

Если в результате получения сервиса возникла ошибка, то провайдер вернет `ServiceObtainError` с исходной ошибкой и подробной информацией.
В ошибке будет информацией об сервисе, в фабрике которого была получена ошибка. Т.к. сервисы зависимы между собой и при получении есть вложенность, то ошибка может возникнуть при получении зависимого сервиса, а не при запросе исходного - для этого в ошибке есть информация о пути до сервиса с ошибкой.


#### An example get ServiceObtainError and nested services:
```swift
struct FirstServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .lazy
    func makeService() throws -> FirstService {
        throw SomeError()
    }
}

struct SecondServiceFactory: ServiceFactory {
    let firstService: ServiceProvider<FirstService>

    let mode: ServiceFactoryMode = .many
    func makeService() throws -> SecondService {
        return SecondServiceImpl(
            firstService: try firstService.getService()
        )
    }
}

do {
    let service = try secondServiceProvider.getService()
} catch {
    // error is ServiceObtainError
    // error.error is SomeError
    
    // error.service = FirstService
    // error.pathServices = [SecondService, FirstService]
    // error.isNested = true
}
```


### Support Objective-C

Creating and configuring the container is only available for swift code, but for objective-c, you can provide a special wrapper to getting the services.

`ServiceProviderObjC` (in Objective-C is visible as `ServiceProvider`) and `ServiceParamsProviderObjC` (in Objective-C is visible as `ServiceParamsProvider`) can be created from any `Service[Params]Provider`, passing it (swift option) to the constructor in the swift code.

You can get the service through selectors:
 - `[ServiceProvider getService]`, 
 - `[ServiceProvider getServiceOrFatal]`, 
 - `[ServiceProvider getServiceAndReturnError:]`,
 - `[ServiceParamsProvider getServiceWithParams:]`,
 - `[ServiceParamsProvider getServiceOrFatalWithParams:]`,
 - `[ServiceParamsProvider getServiceWithParams:andReturnError:]`.


#### An example use ServiceProvider:
```objc
FirstService* firstService = [serviceContainer.firstService getService];

NSError* error = nil;
SecondService* secondService = [serviceContainer.secondService getServiceAndReturnError:&error];

ThirdService* thirdService = [serviceContainer.thirdService getServiceWithParams:@"test"];
```


## Author

[**ViR (Короткий Виталий)**](http://provir.ru)

[Telegram: @ViR_RuS](https://t.me/ViR_RuS)


## License

ServiceContainerKit is released under the MIT license. [See LICENSE](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE) for details.

