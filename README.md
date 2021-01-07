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
  - [Usage ServiceInjects (English / Русский)](#usage-serviceinjects)
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


**Note:** To use the library, remember to include it in each file: `import ServiceContainerKit`.

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


## Usage ServiceInjects 

**Important:** To use the library, remember to include it in each file:  `import ServiceInjects`.

### Introduction

The ServiceContainerKit framework assumes that the project can be divided into two layers - the presentation and service layers.
The presentation layer is the application screens, its visible part of the program, where each screen consists of Views, ViewControllers and their business logic.
The service layer is the business logic of the application itself, auxiliary entities, and everything that is used throughout the application.
To make services and build relationships between them, use `ServiceProvider`.
To provide services for the presentation layer, you can use a container, using which the `ServiceInjects` framework inject dependencies.

It is important to treat the `ServiceInjects` framework like this - this framework is only for the presentation layer, and therefore should only be used from the main thread.
It should not be used to create links between services - only for simple implementation of ready-made services in the screen entity.

For a more visual example, download the project and study the `Example` target.

#

Фреймворк ServiceContainerKit предполагает что проект можно разделить на два слоя - слои презентации и сервисов. 
Слой презентации - это экраны приложения, его видимая часть программы, где каждый экран состоит из Views, ViewControllers и их бизнес логики.
Слой сервисов - это бизнес логика самого приложения, вспомогательные сущности и все что используется во всем приложении. 
Для создания и построения связей между сервисами используется `ServiceProvider`.
Для предоставления сервисов для слоя презентации можно использовать контейнер, используя которой уже фреймворк `ServiceInjects` внедряет зависимости.

Важно относится к фреймворку `ServiceInjects` так - этот фреймворк только для слоя презентации, а значит должен использоваться только из главного потока.
Его не следует использовать для создания связей между сервисами - только для простого внедрения готовых сервисов в сущности экрана.

Для более наглядного примера скачайте проект и изучите таргет `Example`.


### Container and ServiceInjectResolver

In order to be able to inject services anywhere in the application, you need to make at least one container with a simple but necessary rule - its fields must be stored by service providers. Services in the container that do not follow this rule will not be inject in the application.
The field with the service must be of the type `ServiceProvider` or `ServiceParamsProvider`, field nesting is supported because the key is used as a KeyPath.
The container itself can be specified as a protocol - then it only remains to register its implementation.
You must register the container once before using it.

You can find out if the container is already registered - `ServiceInjectResolver.contains(Type.self)`.
You can also subscribe to its registration - `ServiceInjectResolver.addReadyContainerHandler(Type.self) { }`, the clojure will be called immediately if the container is already registered.

#

Для того чтобы была возможность внедрять сервисы в любом месте приложения, требуется создать как минимум один контейнер с простым, но необходимым правилом - его поля должны хранить првайдеры сервисов. Сервисы в контейнере, которые не следуют такому правилу внедрять в приложении не получится. 
Поле с сервисом должно быть типа `ServiceProvider` или `ServiceParamsProvider`, поддерживается вложенность полей т.к. в качестве ключа используется KeyPath.
Сам контейнер может быть указан в виде протокола - тогда остается только зарегистрировать его реализацию.
Перед использованием необходимо зарегистрировать контейнер один раз.

Можно узнать зарегистрирован ли уже контейнер - `ServiceInjectResolver.contains(Type.self)`.
Также можно подписаться на его регистрацию - `ServiceInjectResolver.addReadyContainerHandler(Type.self) { }`, кложур будет вызван сразу если контейнер уже зарегистрирован. 


####  Example of making and registering a container:
```swift
struct Services {
    struct Folders {
        let manager: ServiceProvider<NoteFoldersManager>
    }
    
    struct Notes {
        let manager: ServiceParamsProvider<NoteRecordsManager, NoteRecordsManagerParams>
        let editService: ServiceParamsProvider<NoteRecordEditService, NoteRecordEditServiceParams>
    }
    
    let userService: ServiceProvider<UserService>
    
    let folders: Folders
    let notes: Notes
}

enum ServicesFactory {
    static func makeDefault() -> Services {
        let core = ServicesCore.makeDefault()
        
        let folders = Services.Folders.makeDefault(core: core)
        let notes = Services.Notes.makeDefault(core: core, folders: folders)
        
        return Services(
            userService: core.userService,
            folders: folders,
            notes: notes
        )
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let services = ServicesFactory.makeDefault()
        ServiceInjectResolver.register(services)
        
        ...
    
        return true
    }
}

final class SimpleViewController: UIViewController {
    @ServiceInject(\Services.userService)
    private var userService

    @ServiceInject(\Services.folders.manager)
    private var foldersManager
    
    ...
}
```

### @ServiceInject and @ServiceParamsInject

To inject the service, you need to use `@ServiceInject` and `@ServiceParamsInject`. As a rule, you only need to know its full path - the container type and the path to the provider in it.
Dependency injection can be delayed (`lazyInject = true`), then the service will be getted only when the field is first accessed, or it will not be getted at all if it was not used.

The order of dependency inject and container registration is not important - it is only important that the container is registered before the first access to the service being injected.
If an object was created in which the service is injected before the container is registered, the dependency injection will actually be performed later - immediately after the container is registered (if `lazyInject = false`).

If, for some reason, the service is not injected for the first time and there is not enough information for this (no container or parameters) - there will be a crash. The line on the file in crash will indicate the place of injection of the service.
If during the injection of the service there is an error getting the service - it will also crash, because the `getServiceOrFatal` method is used inside.

#

Для внедрения сервиса нужно использовать `@ServiceInject` и `@ServiceParamsInject`. Как правило необходимо знать только его полный путь - тип контейнера и путь до провайдера в нем.
Внедрение зависимости может быть отложенным (`lazyInject = true`), тогда сервис будет получен только при первом обращении к полю, либо не будет получен вовсе если он не был использован. 

Порядок внедрения зависимости и регистрация контейнера не важна - важно только чтобы контейнер был зарегистрирован до первого обращения к внедряемому сервису.
Если был создан объект в котором внедряется сервис до регистрации контейнера - инъекция зависимости в реальности будет произведена позже - сразу после регистрации контейнера (если `lazyInject = false`).

Если по каким-либо причинам при первом обращении сервис не будет внедрен и не будет достаточно информации для этого (нет контейнера или параметров) - будет краш. Строка на файл в краше при этому будет указывать на место внедрения сервиса. 
Если во время внедрения сервиса будет ошибка получения сервиса - тоже будет краш, т.к. внутри используется метод `getServiceOrFatal`.

#### Example of the order of dependency injection and lazy injection:
```swift
class UserPresenter {
    @ServiceInject(\Services.userService, lazyInject: true)
    private var userService

    @ServiceInject(\Services.folders.manager)
    private var foldersManager
    
    func logout() {
        userService.logout()
        foldersManager.refresh()
    }
}

func testFirst() {
    // ServiceInjectResolver.contains(Services.self) == false

    let presenter = UserPresenter()
    // userService not injected because not found container
    // foldersManager not injected because not found container

    let services = ServicesFactory.makeDefault()
    ServiceInjectResolver.register(services)
    // userService not injected because lazyInject = true
    // foldersManager inject success

    presenter.logout()
    // userService inject success
}

func testSecond() {
    let services = ServicesFactory.makeDefault()
    ServiceInjectResolver.register(services)

    let presenter = UserPresenter()
    // userService not injected because lazyInject = true
    // foldersManager inject success

    presenter.logout()
    // userService inject success
}
```

To inject a service from a provider with parameters, use `@ServiceParamsInject`. Parameters can be set immediately or later.
Parameters can only be specified once, until they are set, the service will not be injected.

You can also get the current injection status from `@ServiceInject` and `@ServiceParamsInject` and even subscribe to it.
The `$setReadyHandler { service in }` method will be called immediately after injection, but before use. If the service is already injected during the handler set, handler will be called immediately.

#

Для внедрения сервиса из провайдера с параметрами нужно использовать `@ServiceParamsInject`. Параметры можно задать сразу или позже.
Параметры указать можно только один раз, пока они не будут указаны, сервис не будет внедрен.

Также у `@ServiceInject` и `@ServiceParamsInject` можно получить текущее состояние внедрения и даже подписаться на него.
Метод `$setReadyHandler { service in }`  будет вызван сразу после инъекции, но до использования. Если во время установки обработчика сервис уже внедрен - он будет вызван сразу.

#### Example of injecting a service with parameters:
```swift
struct Dependencies {
    @ServiceParamsInject(\Services.firstService, params: .init(value: "Default")) var firstService
    @ServiceParamsInject(\Services.secondService, lazyInject: true) var secondService
    
    init(secondValue: String) {
        $secondService.setParameters(.init(value: secondValue))
    }
}

let dependencies = Dependencies(secondValue: "Custom")

// dependencies.$firstService.isReady == true
// dependencies.$secondService.isReady == false
dependencies.$secondService.setReadyHandler { service in
    // Executed in the future before first use, because lazyInject = true
}
```

### @ServiceProviderInject

In some cases, you may not need the service itself, but its source provider. For this purpose, use `@ServiceProviderInject`, passing also the path to the provider.

#

В некоторых случаях может потребоваться не сам сервис, а его исходный провайдер. Для этих целей используется `@ServiceProviderInject`, передав также путь до провайдера. 

#### Example of injecting a provider:
```swift
struct Dependencies {
    @ServiceProviderInject(\Services.firstService) var firstServiceProvider
    @ServiceProviderInject(\Services.secondService) var secondServiceProvider
}

let dependencies = Dependencies()
let firstService = dependencies.firstServiceProvider.getServiceOrFatal()
let secondService = dependencies.secondServiceProvider.getServiceAsOptional()
```


### EntityInjectResolver and @EntityInject

In addition to services it is sometimes necessary to transfer from one place to another in a certain instance.
It is not always possible to use methods or constructors for this, for example, when creating a ViewController through a storyboard.

Such an entity can be temporarily registered in the `EntityInjectResolver`, where the entity will be stored until the first injection or until the corresponding token is deleted.
Entities can be re-registered as many times as you want - the latest version will be used for inject.

To inject an instance for the first use, you need to register using the `EntityInjectResolver.registerForFirstInject(:autoRemoveDelay:)` method.
The entity will be removed automatically from `EntityInjectResolver` after the first injection, but not immediately - but in the next iteration of the main thread cycle, providing the opportunity to inject this entity in several places within the same general main thread cycle. If `autoRemoveDelay != nil` is specified, the instance will also be deleted after the specified number of seconds, if there was no single injection by that time.

If you need to manage the lifetime of an entity in `EntityInjectResolver` yourself, then use the `EntityInjectResolver.register()` method. It will return a token that needs to be stored somewhere. As soon as the token is no longer used, the entity will also be immediately deleted.

For the injection entity, you need to use `@EntityInject(Type.self)` - the original entity will be injected.
You can injected the value of an entity field of any nesting - `@EntityInject(\Type.path)`.

`@EntityInject` can be created before the entity being injected is registered and will be injected as soon as it is registered.

#

Помимо сервисов, иногда необходимо передать из одного места в другое некоторый экземпляр.
Не всегда есть возможность для этого использовать методы или конструкторы, к примеру при создании ViewController-а через сториборд.

Такой объект можно временно зарегистрировать в `EntityInjectResolver`, в котором экземпляр будет храниться до первого внедрения или пока не будет удален соотвествующий ему токен.
Экземпляры можно сколько угодно раз регистрировать повторно - при внедрении будет использоваться самая поздняя версия.

Чтобы внедрить экземпляр до первого использования, нужно зарегистрировать используя метод `EntityInjectResolver.registerForFirstInject(:autoRemoveDelay:)`.
Экземпляр будет удален автоматически из `EntityInjectResolver` после первого внедрения, но не сразу - а в следующей интерации цикла главного потока, предоставляя возможность в рамках одного общего цикла главного потока внедрить этот экземпляр в нескольких местах. Если указан `autoRemoveDelay != nil`, то экземпляр также будет удален спустя указанное кол-во секунд, если к этому времени не было не единого внедрения.

Если временем существования экземпляра в `EntityInjectResolver` нужно управлять самим, то следует использовать метод `EntityInjectResolver.register()`. Он вернет токен, который нужно где-то хранить. Как только токен перестанет использоваться, экземпляр также будет сразу удален.

Для внедрения экземпляра нужно использовать `@EntityInject(Type.self)` - будет внедрен исходный экземпляр.
Можно внедрить значение поля экземпляра любой вложенности - `@EntityInject(\Type.path)`.

`@EntityInject` может быть создан до регистрации внедряемого экземпляра и будет внедрен сразу как он будет зарегистрирован.


#### Example of injecting a entity:
```swift
var token: EntityInjectToken?
token = EntityInjectResolver.register(appSettings)

extension SimpleViewController {
    /// Maked in Storyboard, perform `prepareForMake()` can be before or after make.
    static func prepareForMake() {
        let presenter = SimplePresenterImpl()
        EntityInjectResolver.registerForFirstInject(presenter)
    }
}

class SimpleViewController: UIViewController {
    @EntityInject(SimplePresenter.self)
    private var presenter
    
    @EntityInject(\AppSettings.common.uiConfig)
    private var uiConfig
    
    ...
}
```

### Support Objective-C

In Objective-C, KeyPath and structs are not supported, so using `@ServiceInject` and `@EntityInject` is not possible.
But there is support for `ServiceProviderObjC`, using which you can access services.

One of the ways to solve the problem is to use a separate container for objc code, when creating which objc providers will be injected.
Or use a singleton container with all services at once.

To inject providers with the `ServiceProviderObjC` type, use `@ServiceProviderInject` with the objc version of the constructor.

#

В Objective-C не поддерживается KeyPath и структуры, поэтому испоьзование `@ServiceInject` и `@EntityInject` невозможно.
Но есть поддержка `ServiceProviderObjC`, используя который можно получить доступ к сервисам.

Один из вариантов как можно решить проблему - использовать отдельный контейнер для objc кода, создавая который будут внедряться провайдеры.
Либо использовать контейнер синглетон со всеми сервисами сразу.

Для внедрения провайдеров с типом `ServiceProviderObjC` используется `@ServiceProviderInject` с objc версией конструктора.

#### Example objc container:
```swift
@objc(Services)
class ServicesObjC: NSObject {
    @objc static let shared = ServicesObjC()

    @ServiceProviderInject(objc: \Services.firstService)
    @objc var firstService
    
    @ServiceProviderInject(objc: \Services.secondService)
    @objc var secondService
    
    @ServiceProviderInject(objc: \Services.withParamsService)
    @objc var withParamsService
}
```
```objc
FirstService* firstService = [Services.shared.firstService getService];
WithParamsService* withParamsService = [Services.shared.withParamsService getServiceWithParams:@"test"];

NSError* error = nil;
SecondService* secondService = [Services.shared.secondService getServiceAndReturnError:&error];
```


## Author

[**ViR (Короткий Виталий)**](http://provir.ru)

[Telegram: @ViR_RuS](https://t.me/ViR_RuS)


## License

ServiceContainerKit is released under the MIT license. [See LICENSE](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE) for details.

