# Use `set -o pipefail &&` to make xcpretty exit with the same code as xcodebuild.
# Use bash with pipefail option for all jobs
SHELL=/bin/zsh -o pipefail

# Define xcbeautify
define xcbeautify
  if [ -z "$(GITHUB_ACTIONS)" ]; then \
    swift run -c release --package-path ./BuildTools xcbeautify; \
  else \
    swift run -c release --package-path ./BuildTools xcbeautify --renderer github-actions; \
  fi
endef

test_ios:
	xcodebuild test -scheme BonMot -destination "platform=iOS Simulator,name=iPhone 15" -resultBundlePath test-results-ios/Bonmot-iOS.xcresult | $(call xcbeautify)

test_macos:
	xcodebuild test -scheme BonMot -destination "platform=macOS,arch=arm64" -resultBundlePath test-results-macos/Bonmot-macOS.xcresult | $(call xcbeautify)

test_tvos:
	xcodebuild test -scheme BonMot -destination "platform=tvOS Simulator,name=Apple TV" -resultBundlePath test-results-tvos/Bonmot-tvOS.xcresult | $(call xcbeautify)

test_watchos:
	xcodebuild test -scheme BonMot -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" -resultBundlePath test-results-watchos/Bonmot-watchOS.xcresult | $(call xcbeautify)

clean_if_required:
	rm -rf test-results-macos test-results-ios test-results-watchos test-results-tvos

# Platforms listed in order of convenience to run, so if there's a failure early it's easier to test.
test_all: test_macos test_ios test_tvos test_watchos
