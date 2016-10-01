![VaporAPNS](https://cloud.githubusercontent.com/assets/4346200/19014987/344c5014-87fb-11e6-8727-3a687117c17e.png)

# VaporAPNS

![Swift](http://img.shields.io/badge/swift-3.0-brightgreen.svg)
![Vapor](https://img.shields.io/badge/Vapor-1.0-green.svg)
[![Crates.io](https://img.shields.io/crates/l/rustc-serialize.svg?maxAge=2592000)]()

VaporAPNS is a simple, yet elegant, Swift library that allows you to send Apple Push Notifications using HTTP/2 protocol in Linux & macOS.

## 🔧 Installation

A quick guide, step by step, about how to use this library.

### 1- Install libcurl with http/2 support

In macOS using `brew` you can easily do with:

```shell
brew reinstall curl --with-openssl --with-nghttp2
brew link curl --force
```

### 2- Prepare certificates

Create your APNS certificates, then export as `P12` file without a password. Then proceed in this way in your shell:

```shell
openssl pkcs12 -in Certificates.p12 -out push.crt.pem -clcerts -nokeys
openssl pkcs12 -in Certificates.p12 -out push.key.pem -nocerts -nodes
```

### 3- Add VaporAPNS to your project

Add the following dependency to your `Package.swift` file:

```swift
.Package(url:"https://github.com/matthijs2704/vapor-apns.git", majorVersion: 0, minor: 1)
```

And then run `vapor fetch` command, if you have the Vapor toolbox installed.

## 🚀 Usage

It's really easy to get started with the VaporAPNS library! First you need to import the library, by adding this to the top of your Swift file:
```swift
import VaporAPNS
```

Then you need to get yourself an instance of the VaporAPNS class:
```swift
let vaporAPNS = try VaporAPNS(certPath: "/your/path/to/the/push.crt.pem", keyPath: "/your/path/to/the/push.key.pem")
```

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


After we've created the payload it's time to actually send the push message. To do so, we have to create an ApplePushMessage object, by doing:
```swift
let pushMessage = ApplePushMessage(topic: "nl.logicbit.TestApp", priority: .immediately, payload: payload, deviceToken: "488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7", sandbox: true)
```
`topic` being the build identifier of your app. 
Priority can either be `.energyEfficient` or `.immediately`. What does that mean? In short, immediately will `.immediately` deliver the push notification and `.energyEfficient` will take power considerations for the device into account. Use `.immediately` for normal message push notifications and `.energyEfficient` for content-available pushes.
`deviceToken` is the notification registration token of the device you want to send the push to.
`sandbox` determines to what APNS server to send the push to. Pass `true` for development and `false` for production.

Now you can send the notification using:
```swift
let result = vaporAPNS.send(applePushMessage: pushMessage)
```

You can use `result` to handle an error or a success. (Also see the Result enum)

Done!

## ⭐ Contributing

Be welcome to contribute to this project! :)

## ❓ Questions

You can join the Vapor [slack](http://vapor.team). Or you can create an issue on GitHub.

## ⭐ License

This project was released under the [MIT](LICENSE.md) license.
