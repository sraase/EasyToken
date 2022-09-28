Easy Token (non-official)
=========================

Easy Token is an RSA SecurID-compatible software authenticator for Android
with advanced usability features:

* Convenient lock screen and home screen widgets provide instant tokencodes
without navigating to an app.
* Optionally save your PIN.
* Supports SDTID files, importing http://127.0.0.1/... tokens from email,
and QR tokens.
* 100% open source

## Downloads

This version does not provide official binaries.

## Support

Please file issues using the Issues tab.

## Screenshots

![screenshot-0](screenshots/screenshot-0.png)&nbsp;
![screenshot-1](screenshots/screenshot-1.png)

![screenshot-2](screenshots/screenshot-2.png)&nbsp;
![screenshot-3](screenshots/screenshot-3.png)

## Building from source

On the host side you'll need to install:

* Android SDK 33 (use Android Studio to install)
* Android NDK r25b, nominally under /opt/android-ndk-r25b
* Host-side gcc, make, etc. (Red Hat "Development Tools" group or Debian build-essential)
* git, autoconf, automake, and libtool

First, clone the source trees:

    git clone https://github.com/sraase/EasyToken
    cd EasyToken
    git submodule update --init

Then build the binary components (app/src/main/jniLibs/ directory):

    make -C external NDK=/opt/android-ndk-r25b

Create the local.properties file to point at the Android SDK
folder (which contains the tools/ and platform-tools/ folders):

    echo "sdk.dir=/path/to/android/sdk" > local.properties

Then build and install the actual application:

    ./gradlew assemble
    adb install app/build/outputs/apk/debug/app-debug.apk

## Security considerations

Please use Easy Token responsibly and avoid taking unnecessary risks with
sensitive data.  All software tokens are at risk of theft by malware; for
high-security applications a hardware token is strongly preferred.

Saving your PIN is convenient, but can be risky if your device is stolen.

If you use the lock screen widget, your tokencode is available to anybody with
access to your phone (even if they cannot unlock it).  For this case, you may
want to ask your system administrator to issue a 6-digit PIN-less software
token, which will require you to enter PIN + TOKENCODE when logging in, instead
of just a tokencode.
