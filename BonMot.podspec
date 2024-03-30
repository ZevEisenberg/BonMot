Pod::Spec.new do |s|
  s.name             = "BonMot"
  s.version          = "6.1.3"
  s.summary          = "Beautiful, easy attributed strings in Swift"
  s.swift_versions    = ["5.8", "5.9", "5.10"]
  s.description      = <<-DESC
  BonMot removes all the mystery from creating beautiful, powerful attributed strings in Swift.
                       DESC
  s.homepage         = "https://github.com/Rightpoint/BonMot"
  s.license          = 'MIT'
  s.author           = { "Zev Eisenberg" => "zev@zeveisenberg.com" }
  s.source           = { :git => "https://github.com/Rightpoint/BonMot.git", :tag => s.version.to_s }
  # Setting the twitter url is causing builds to fail due to not being able to reach twitter.
  # s.social_media_url = 'https://twitter.com/ZevEisenberg'
  s.requires_arc = true

  s.ios.deployment_target = '12.0'
  s.ios.source_files = 'Sources/**/*.swift'

  s.tvos.deployment_target = '12.0'
  s.tvos.source_files = 'Sources/**/*.swift'

  s.osx.deployment_target = '10.15'
  s.osx.source_files = 'Sources/*.swift'

  s.watchos.deployment_target = '4.0'
  s.watchos.source_files = 'Sources/*.swift'

end
