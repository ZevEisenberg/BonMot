# Use `set -o pipefail &&` to make xcbeautify exit with the same code as xcodebuild.

test_ios:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=iOS Simulator,name=iPhone 15" | xcbeautify

test_macos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination platform=macOS,arch=arm64 | xcbeautify

test_tvos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=tvOS Simulator,name=Apple TV" | xcbeautify

test_watchos:
	set -o pipefail && xcodebuild test -scheme BonMot -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" | xcbeautify

# Platforms listed in order of convenience to run, so if there's a failure early it's easier to test.
test_all: test_macos test_ios test_tvos test_watchos
