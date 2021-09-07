Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '13.0'
s.name = "SSPager"
s.summary = "SSPager."
s.requires_arc = true
s.version = "0.0.4"

s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Eido Goya" => "eido9oya@gmail.com" }
s.homepage = "https://github.com/9oya/SSPager"

s.source = { :git => "https://github.com/9oya/SSPager.git",
             :tag => "#{s.version}" }

s.framework = "UIKit"

s.source_files = "SSPager/**/*.{h,m,swift}"
# s.resources = "SSPager/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
s.swift_version = "5.4"

end
