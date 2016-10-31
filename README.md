![VaporAPNS](https://cloud.githubusercontent.com/assets/4346200/19014987/344c5014-87fb-11e6-8727-3a687117c17e.png)

# VaporAPNS

![Swift](http://img.shields.io/badge/swift-3.0-brightgreen.svg)
![Vapor](https://img.shields.io/badge/Vapor-1.1-green.svg)
[![Crates.io](https://img.shields.io/crates/l/rustc-serialize.svg?maxAge=2592000)]()
[![Build Status](https://travis-ci.org/matthijs2704/vapor-apns.svg?branch=master)](https://travis-ci.org/matthijs2704/vapor-apns)

VaporAPNS is a simple, yet elegant, Swift library that allows you to send Apple Push Notifications using HTTP/2 protocol in Linux & macOS. It has support for the brand-new [Token Based Authentication](https://developer.apple.com/videos/play/wwdc2016/724/) but if you need it, the traditional certificate authentication method is ready for you to use as well. Choose whatever you like!

## 🔧 Installation

A quick guide, step by step, about how to use this library.

### 1- Install libcurl with http/2 support

In macOS using `brew` you can easily do with:

```shell
brew reinstall curl --with-openssl --with-nghttp2
brew link curl --force
```

### 2- Add VaporAPNS to your project

Add the following dependency to your `Package.swift` file:

```swift
.Package(url:"https://github.com/matthijs2704/vapor-apns.git", majorVersion: 1, minor: 1)
```

And then run `vapor fetch` command, if you have the Vapor toolbox installed.

## 🚀 Usage

It's really easy to get started with the VaporAPNS library! First you need to import the library, by adding this to the top of your Swift file:
```swift
import VaporAPNS
```
### 🔒 Authentication methods
Then you need to get yourself an instance of the VaporAPNS class:
There are two ways you can initiate VaporAPNS. You can either use the new authentication key APNS authentication method or the 'old'/traditional certificates method.
#### 🔑 Authentication key authentication (preferred)
This is the easiest to setup authentication method. Also the token never expires so you won't have to renew the private key (unlike the certificates which expire at a certain date).
```swift
let options = try! Options(topic: "<your bundle identifier>", teamId: "<your team identifier>", keyId: "<your key id>", keyPath: "/path/to/your/APNSAuthKey.p8")
let vaporAPNS = try VaporAPNS(options: options)
```
#### 🎫 Certificate authentication
If you decide to go with the more traditional authentication method, you need to convert your push certificate, using:
```shell
openssl pkcs12 -in Certificates.p12 -out push.crt.pem -clcerts -nokeys
openssl pkcs12 -in Certificates.p12 -out push.key.pem -nocerts -nodes
```
After you have those two files you can go ahead and create a VaporAPNS instance:
```swift
let options = try! Options(topic: "<your bundle identifier>", certPath: "/path/to/your/certificate.crt.pem", keyPath: "/path/to/your/certificatekey.key.pem")
let vaporAPNS = try VaporAPNS(options: options)
```
### 📦 Push notification payload
After you have the VaporAPNS instance, we can go ahead and create an Payload:
There are multiple quick ways to create a push notification payload. The most simple one only contains a body message:
```swift
let payload = Payload(message: "Your push message comes here")
```
Or if you need a Payload with a title and a message:
```swift
let payload = Payload(title: "Title", body: "Your push message comes here")
```
Or you can create a content-available push payload using:
```swift
let payload = Payload.contentAvailable
```

If you want a more advanced way of creating a push payload, you can create the Payload yourself:
(This example creates a localized push notification with Jena and Frank as passed arguments)
```swift
let payload = Payload()
payload.bodyLocKey = "GAME_PLAY_REQUEST_FORMAT"
payload.bodyLocArgs = [ "Jenna", "Frank" ]
```
The possibilities are endless!

### 🚀 Send it!

After we've created the payload it's time to actually send the push message. To do so, we have to create an ApplePushMessage object, by doing:
```swift
let pushMessage = ApplePushMessage(topic: "nl.logicbit.TestApp", priority: .immediately, payload: payload, sandbox: true)
```
`topic` being the build identifier of your app. This is an *optional* parameter. If left out or `nil` it'll use the topic from Options you've provided in the initializer.  
Priority can either be `.energyEfficient` or `.immediately`. What does that mean? In short, immediately will `.immediately` deliver the push notification and `.energyEfficient` will take power considerations for the device into account. Use `.immediately` for normal message push notifications and `.energyEfficient` for content-available pushes.  
`sandbox` determines to what APNS server to send the push to. Pass `true` for development and `false` for production.

Now you can send the notification to just one device, using:
```swift
let result = vaporAPNS.send(pushMessage, to: "488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7")
```
The `to` string is the `deviceToken`, which is the notification registration token of the device you want to send the push to.  
You can use `result` to handle an error or a success. (Also see the Result enum)



Or you can send the notification to multiple deviceTokens using:
```swift
vaporAPNS.send(pushMessage, to: ["488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7", "2d11c1a026a168cee25690f2770993f6068206b1d11d54f88910b8166b23f983"]) { result in
    print(result)
    if case let .success(messageId,deviceToken,serviceStatus) = result, case .success = serviceStatus {
        print ("Success!")
    }
}
```
The block at the end is called every time a push notification is sent (you can handle errors here per notification. `to` has now changed from a String into an [String]


Done!

## ⭐ Contributing

Be welcome to contribute to this project! :)

## ❓ Questions

You can join the Vapor [slack](http://vapor.team). Or you can create an issue on GitHub.

## ⭐ License

This project was released under the [MIT](LICENSE.md) license.
