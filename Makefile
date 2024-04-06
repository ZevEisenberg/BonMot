# Use `set -o pipefail &&` to make xcpretty exit with the same code as xcodebuild.

test_ios:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=iOS Simulator,name=iPhone 15" | bundle exec xcpretty --report junit --output test-results-ios/report.xml

test_macos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination platform=macOS,arch=arm64 | bundle exec xcpretty --report junit --output test-results-macos/report.xml

test_tvos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=tvOS Simulator,name=Apple TV" | bundle exec xcpretty --report junit --output test-results-tvos/report.xml

test_watchos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" | bundle exec xcpretty --report junit --output test-results-watchos/report.xml

# Platforms listed in order of convenience to run, so if there's a failure early it's easier to test.
test_all: test_macos test_ios test_tvos test_watchos
