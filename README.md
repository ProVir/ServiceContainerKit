![ServiceContainerKit](https://raw.githubusercontent.com/ProVir/ServiceContainerKit/master/ServiceContainerKitLogo.png) 

[![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ProVir/ServiceContainerKit)
[![Platform](https://cocoapod-badges.herokuapp.com/p/ServiceContainerKit/badge.png)](http://cocoapods.org/pods/ServiceContainerKit)
[![License](https://cocoapod-badges.herokuapp.com/l/ServiceContainerKit/badge.png)](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE)

  Kit to create your own IoC Container or ServiceLocator. Also includes a ServiceLocator as an option. Require Swift 4 and above, support Objective-C in readOnly regime. 

  *Dependency Inversion Principle (DIP from SOLI**D**)* allows you to create classes as independent as possible between each other. But writing the services using Dependency Injection, you are faced with the difficulty - how and where to set up services and communications, and how to provide these services to objects that are created during the application process, usually a presentation layer.
  One way to solve this problem is to use *Dependency Injection Container* frameworks that create services for the dependencies and settings that you specify, and also if necessary, injected them in the right parts of the application. The use of such side-by-side frameworks draws certain dependencies throughout the architecture of the application and provides its functionality with certain limitations, which are discussed by the nuances of the programming language, platforms, and as a payment for their universality.
  You can create your own container for a specific project, taking into account its specific features and architecture. One simple way to create your own container is to use a structure with a set of pre-configured services or their factories. Better yet, use a wrapper over services (`ServiceProvider`), which hides the way to create a service - for earlier or as needed, as well as its dependencies and the settings used. Also, as a container, you can use `ServiceLocator`, which is usually a singletone itself.

#

*Dependency Inversion Principle (DIP из SOLI**D**)* позволяет создавать классы максимально независимыми между собой. Но писав сервисы используя DIP вы сталкиваетесь с трудностью - как и где настроить сервисы и связи, а также как предоставить эти сервисы объектам, которые создаются в процессе работы приложения, как правило это слой представления. 
  Один из способов решить эту проблему - это использование фреймворков *Dependency Injection Container*, которые создают сервисы по указываемым вами зависисмостям и настройкам, а также внедряют их по необходимости в нужные части приложения. Использование подобных стороних фреймворков тянет за собой наличие определенных зависимостей во всей архитекртуре приложения и предоставляют свой функционал с определенными ограничениями, которые обсуловлены нюансами языка программирования, платформы и как плата за их универсальность.  
  Вы можете создать свой собственный контейнер для конкретного проекта с учетом его специфики и архитектуры. Один из простых способов создать свой контейнер - это использовать структуру с набором созданных и настроенных заранее сервисов либо их фабрик. А еще лучше - использовать обертку над сервисами (`ServiceProvider`), скрывающую способ создания сервиса - за ранее или по необходимости, а также его заисимости и используемые настройки. Также в качестве контейнера можно использовать `ServiceLocator`, как правило являющийся сам по себе синглетоном. 

#

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage ServiceFactory (English / Русский)](#usage-servicefactory)
- [Usage IoC Container and ServiceProvider (English / Русский)](#usage-ioc-container-and-serviceprovider)
- [Usage ServiceLocator (English / Русский)](#usage-servicelocator)
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

### Service[Params]Provider

You can create `ServiceProvider` in several ways:
- using a regular factory: by calling function `ServiceFactory().serviceProvider()` (recommended) or through constructors `ServiceProvider(factory:)` and `ServiceProvider(tryFactory:)`;
- using factory with parameters: by calling function `ServiceFactory().serviceProvider(params:)` (recommended) or through constructor `ServiceProvider(factory:,params:)`;
- using provider with parameters: `ServiceParamsProvider.convert(params:)`;
- using an already created service, passing it to the constructor: `ServiceProvider()`, factory equivalent of `atOne` type;
- using closures in lazy mode or generating a new instance each time: `ServiceProvider(lazy:{ })` и `ServiceProvider(factory:{ })`, factory equivalent of  `lazy` and `many` types.

You can create `ServiceParamsProvider` only by using a factory with parameters (`ServiceParamsFactory`): `ServiceParamsProvider(factory:)`.

Examples of creating `Service[Params]Provider` are shown in the example above with the IoC Container.

To get the service it is enough to call the function `Service[Params]Provider.getService()` which returns the service as an option, `nil` will be returned in case of a service error. You can also use `Service[Params]Provider.tryService()` - then the service is returned not as an option and can generate an error why the service was not getted (unlike `getService()`, which simply returns `nil`).

#

Создать `ServiceProvider` можно несколькими способами:
- используя обычную фабрику: через вызов `ServiceFactory().serviceProvider()` (рекомендуется) или через конструкторы `ServiceProvider(factory:)` и `ServiceProvider(tryFactory:)`;
- используя фабрику с параметрами: через вызов `ServiceFactory().serviceProvider(params:)` (рекомендуется) или через конструктор `ServiceProvider(factory:,params:)`;
- используя провайдер с параметрами: `ServiceParamsProvider.convert(params:)`;
- используя уже созданный сервис, передав его в конструктор: `ServiceProvider()`, эквивалент фабрики типа `atOne`;
- используя кложуры в lazy режиме или генерируя каждый раз новый экземпляр: `ServiceProvider(lazy:{ })` и `ServiceProvider(factory:{ })`, эквиваленты фабрик типов `lazy` и `many`.

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


## Usage ServiceLocator

If you use CocoaPods, then to use ServiceLocator it should be enabled explicitly:
```ruby
target '<Your Target Name>' do
  pod 'ServiceContainerKit/ServiceLocator'
end
```

ServiceLocator is IoC Container, but unlike its implementation above, the services in it are stored by the key, which is the name of the class or service protocol. We simply add services to ServiceLocator and get them on demand based on the return type using generics. Also ServiceLocator is often used as a singleton - that solves the problem of dependency injection, because we can get any service from anywhere in the code. It is well suited for quick solutions or in small projects, but it can create problems in large projects, over which several developers work.

From the minuses - in one ServiceLocator we can store only one instance of a service or factory, while in our custom IoC Container we are not limited to this. Also do not forget that ServiceLocator is an antipattern and it should be used very carefully and do not forget about compliance with *Dependency Inversion Principle (DIP from SOLI**D**)*. ServiceLocator, unlike its IoC Container, does not tell us directly which services it contains, but if you store services based on protocols, then there is generally no exact information on how to get the service - by protocol or a specific implementation.

As a solution "somewhere in the middle" when choosing between its IoC Container and the proposed ServiceLocator in framework, write your ServiceLocator singleton, in which all services will be as separate ServiceProviders, as described in the IoC Container section.

#

  ServiceLocator - это IoC Container, но в отличие от своей реализации приведенной выше, сервисы в нем хранятся по ключу, в качестве которого выступает имя класса или протокола сервиса. Мы просто добавляем сервисы в ServiceLocator и получаем их по требованию на основе выводимого типа используя дженерики. Также ServiceLocator часто используется как синглетон - что решает проблему внедрения зависимостей, т.к. мы можем получить любой сервис из любого места в коде. Он хорошо подходит для быстрого решения или в небольших проектах, но может создать проблемы в больших проектах, над которыми работают несколько разработчиков. 
  
  Из минусов - в одном ServiceLocator мы можем хранить только один экземпляр сервиса или фабрики, в то время как в своем IoC Container мы этим не ограничиваемся. Также не стоит забывать что ServiceLocator - это антипаттерн и его следует использовать очень осторожно и не забывать про соблюдение *Dependency Inversion Principle (DIP from SOLI**D**)*. ServiceLocator в отличие от своего IoC Container не сообщает нам напрямую какие именно сервисы он в себе содержит, а если хранить сервисы на основе протоколов, то вообще нет точной информации как получить сервис - по протоколу или конкретной реализации. 

  В качестве решения "где-то по середине" при выборе между своим IoC Container и предлагаемой фреймворком ServiceLocator - написать свой синглетон ServiceLocator, в котором все сервисы будут в качестве отдельных ServiceProvider, как приведено в разделе о IoC Container. 


### Add and remove Services

ServiceLocator for storing services always uses ServiceProvider. You can always get not only the service itself, but also its ServiceProvider. To add services, you can use:
- using the already created `ServiceProvider` or` ServiceParamsProvider` (recommended): `ServiceLocator.addService(provider:)`;
- using a factory:  `ServiceLocator.addService(factory:)`;
- using an already created service: `ServiceLocator.addService()`, factory equivalent of `atOne` type;
- using closures in lazy mode or generating a new instance each time:  `ServiceLocator.addLazyService { }` and  `ServiceLocator.addService { }`, factory equivalent of `lazy` and `many` types.

To remove a service, use `ServiceLocator.removeService(serviceType:)`.

To protect ServiceLocator from changes after configuration, call `ServiceLocator.setReadOnly()`. In the ReadOnly mode, any change will generate assert.
Any ServiceLocator can be cloned with its services with the possibility of further modification - `ServiceLocator.clone()`. 

#

  ServiceLocator для хранения сервисов всегда использует ServiceProvider. Всегда можно получить не только сам сервис, но и его ServiceProvider. Для добавления сервисов вы можете использовать:
- используя уже созданный `ServiceProvider` или  `ServiceParamsProvider` (рекомендуется): `ServiceLocator.addService(provider:)`;
- используя фабрику:  `ServiceLocator.addService(factory:)`;
- используя уже созданный сервис: `ServiceLocator.addService()`, эквивалент фабрики типа `atOne`;
- используя кложуры в lazy режиме или генерируя каждый раз новый экземпляр:  `ServiceLocator.addLazyService { }` и  `ServiceLocator.addService { }`, эквиваленты фабрик типов `lazy` и `many`.

  Для удаления сервиса используйте `ServiceLocator.removeService(serviceType:)`.

  Чтобы защитить ServiceLocator от изменений после настройки, следует вызвать `ServiceLocator.setReadOnly()`. В ReadOnly режиме любое изменение будет генерировать assert. 
  Любой ServiceLocator можно клонировать с его сервисами с возможностью дальнейшего изменения - `ServiceLocator.clone()`. 


#### An example add services to ServiceLocator:
```swift
let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
let lazyServiceProvider = LazyServiceFactory().serviceProvider()

let serviceLocator = ServiceLocator()

serviceLocator.addService(provider: singletonServiceProvider)
serviceLocator.addService(provider: lazyServiceProvider)

serviceLocator.addService(factory: FirstServiceFactory(singletonServiceProvider: singletonServiceProvider))
serviceLocator.addService(sharedTestService as TestServiceShared) //TestServiceShared is protocol

serviceLocator.addLazyService {
    LazySecondService()
}

serviceLocator.addService {
    ThirdService()
}

serviceLocator.setReadOnly()
```

### Share ServiceLocator

ServiceLocator can be used as a singleton. Singleton is available using the static property `ServiceLocator.shared`. It can be set with a static function `ServiceLocator.setupShared(serviceLocator:ServiceLocator,readOnlySharedAfter:Bool=true)`. The parameter `readOnlySharedAfter` with the value `true` (default) forbids changing the singleton itself. To prevent a full change to the ServiceLocator, remember to call `setReadOnly()`.

#

  ServiceLocator можно использовать как синглетон. Синглетон доступен по статичному свойству `ServiceLocator.shared`. Его можно задать статитичной функцией `ServiceLocator.setupShared(serviceLocator:ServiceLocator,readOnlySharedAfter:Bool=true)`. Параметр `readOnlySharedAfter` со значением `true` (default) запрещает менять сам синглетон. Чтобы запретить полное изменение ServiceLocator следует не забыть вызвать `setReadOnly()`.  

#### An example setup shared ServiceLocator:
```swift
serviceLocator.setReadOnly()
ServiceLocator.setupShared(serviceLocator: serviceLocator, readOnlySharedAfter: true)
```

### Get Services

To get the service it is enough to call the function `ServiceLocator.getService()` which returns the service as an option, `nil` will be returned in case of a service error. The type of the service is displayed itself, but you can use `as` to specify the type yourself. You can also use `ServiceLocator.tryService()` - then the service is returned not as an option and can generate an error why the service was not received (unlike `getService()`, which simply returns `nil`).
To get a service from a singleton, you can use the static functions `ServiceLocator.getServiceFromShared()` and `ServiceLocator.tryServiceFromShared()`, or get the ServiceLocator itself via `ServiceLocator.shared`.
To get ServiceProvider of a specific service - `ServiceLocator.getServiceProvider()`. 

#

  Для получения сервиса достаточно вызвать функцию `ServiceLocator.getService()` которая возвращает сервис как опционал, `nil` будет возвращен в случае ошибки получения сервиса. Тип сервиса выводится сам, но можно воспользоваться `as` для указания типа самостоятельно. Также можно использовать `ServiceLocator.tryService()` - тогда сервис возвращается не как опционал и может генерировать ошибку почему сервис не был получен (в отличие от `getService()`, который просто вернет `nil`). 
  Для получени сервиса из синглетона можно воспользоваться статичными функциями `ServiceLocator.getServiceFromShared()` и `ServiceLocator.tryServiceFromShared()`, либо получить сам ServiceLocator через `ServiceLocator.shared`. 
  Для получения ServiceProvider конкретного сервиса - `ServiceLocator.getServiceProvider()`. 
  
#### An example get services:
```swift
let firstService: FirstService = serviceLocator.getService()!
let secondService = (ServiceLocator.getServiceFromShared() as SecondService?)!

let thirdService: ThirdServicing
do {
    thirdService = ServiceLocator.tryServiceFromShared() as ThirdServicing
} catch {
    fatalError("Error get thirdService: \(error)")
}

let paramsService: ParamsService = serviceLocator.getService(params: "test")!
```

If a factory with parameters is used for the service, then to support its parameters in the ServiceLocator, it should be indicated through the protocol that the service itself can be getted with certain parameters. In order for ServiceLocator to getting the service without passing parameters, the parameter type in the factory must be optional.

Если для сервиса используется фабрика с параметрами, то для поддержки ее параметров в ServiceLocator следует через протокол указать что сам сервис может быть получен с определнными параметрами. Для того чтобы ServiceLocator мог получить сервис без передачи параметров, тип параметра в фабрике должен быть опциональным. 

#### An example params factory:
```swift
//Support params for ServiceLocator (not optional).
extension ParamsService: ServiceSupportFactoryParams {
    typealias ParamsType = String
}

struct ParamsServiceFactory: ServiceParamsFactory {
    /// Optional params for support get service without params in ServiceLocator. 
    func createService(params: String?) throws -> ParamsService {
        return ParamsService(text: params ?? "")
    }
}
```

### Support Objective-C

Creating and configuring the ServiceLocator is only available for swift code, but for objective-c, you can only get the services.

`ServiceLocatorObjC` (in Objective-C is visible as `ServiceLocator`) can be created from any `ServiceLocator`, passing it (swift option) to the constructor in the swift code. Also use empty contructor (available in objective-c code) for use ServiceLocator.shared. Avaialble static selectors used equalent `ServiceLocator.getServiceFromShared()` and `ServiceLocator.tryServiceFromShared()`.


You can get the service through selectors (from instance or class):
- Get service as class: `[ServiceLocator getServiceWithClass:]` and `[ServiceLocator getServiceWithClass:error:]`; 
- Get service as protocol: `[ServiceLocator getServiceWithProtocol:@protocol()]` and `[ServiceLocator getServiceWithProtocol:@protocol() error:]`; 
- Get service as class with parameters: `[ServiceLocator getServiceWithClass:params:]` and `[ServiceLocator getServiceWithClass:params:error:]`; 
- Get service as protocol with parameters: `[ServiceLocator getServiceWithProtocol:@protocol() params:]` and `[ServiceLocator getServiceWithProtocol:@protocol() params: error:]`; 


#### An example use ServiceLocator:
```objc
ServiceLocator* locator = [ServiceLocator new]; //Used ServiceLocator.shared
FirstService* firstService = [locator getServiceWithClass:FirstService.class];

NSError* error = nil;
SecondService* secondService = [ServiceLocator getServiceWithClass:SecondService.class error:&error];

id<ThirdServicing> thirdService = [ServiceLocator getServiceWithProtocol:@protocol(ThirdServicing)];

ParamsService* paramsService = [ServiceLocator getServiceWithClass:ParamsService.class params:@"test"];
```


## Author

[**ViR (Короткий Виталий)**](http://provir.ru)


## License

ServiceContainerKit is released under the MIT license. [See LICENSE](https://github.com/ProVir/ServiceContainerKit/blob/master/LICENSE) for details.

