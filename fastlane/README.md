fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
### setup
```
fastlane setup
```
Download certificates and provisioning profiles

handy to run if you're having issues with certs & profiles.
### dry_run
```
fastlane dry_run
```
Makes sure that Fastlane is setup and working by posting a message to Slack
### release_notes
```
fastlane release_notes
```
Generates release notes
### beta
```
fastlane beta
```
Submit a build to testflight
### store
```
fastlane store
```
Submit a build to the app store
### refresh_dsyms
```
fastlane refresh_dsyms
```
Downloads dSyms from Apple, and uploads them to Crashlytics

  Options:

      version:x.y.z (defaults to ENV[VERSION_NUMBER])

      build:1234 (defaults to latest build number)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
