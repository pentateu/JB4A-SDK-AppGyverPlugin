# Journey Builder for APPS SDK  - Plugin for AppGyver (http://appgyver.com)

AppGyver plugin that implements the Journey Builder for APPS SDK to add push functionality to your AppGyver app.

## This plugins is based on the Cordova version: https://github.com/ExactTarget/JB4A-SDK-CordovaPlugin

## Release History

### Version 1.0
First Version with basic Plugin setup.


## Installing the Plugin

Follow these [instructions](https://code.exacttarget.com/mobilepush/integrating-mobilepush-sdk-your-ios-mobile-app#How) for ios to provision and setup your [Code@ExactTarget](http://code.exacttarget.com) apps

Follow these [instructions](https://code.exacttarget.com/mobilepush/integrating-mobilepush-sdk-your-android-mobile-app#How) for android to provision and setup your [Code@ExactTarget](http://code.exacttarget.com) apps

Once provisioning and [Code@ExactTarget](http://code.exacttarget.com) apps are setup we can configure the plugin installation on AppGyver's build service.

You will need to provide the following variables:

```
--variable DEVAPPID='427c085f-5358944f2-a8f7-bbc5150c77c5'
--variable DEVACCESSTOKEN='yay73bzx6eygw8ypaqr67fvt'
--variable PRODAPPID='35a19ebc-50ae-4ed5-9d6c-404290ada3cd'
--variable PRODACCESSTOKEN='cghknp9rjrmk9pkf6qh392u3'
--variable GCMSENDERIDDEV='123456'
--variable GCMSENDERIDPROD='123456'
--variable USEGEO='true'
--variable USEANALYTICS='true'
```

**be sure to replace the values below with your Code@ET app ids/access tokens and the GCM Sender IDs.


## Previous Release History

### Version 1.1.0
_Released November 17, 2014_

* Updated to use the 3.3.0 Journey Builder for APPS SDK.
* Support for Xcode 6 added as well as iOS8.
* get methods for attributes and device information added.

### Version 1.0.1
_Released June 19, 2014_

* Custom key functionality and callbacks to Javascript from native added.

### Version 1.0.0
_Released June 10, 2014_

* First public version live
* Uses iOS SDK version 3.1.1 and android version 3.1.2
