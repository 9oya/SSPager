Pod::Spec.new do |s|

    s.platform = :ios
    s.ios.deployment_target = '13.0'
    s.name = "SSPager"
    s.summary = "SSPager."
    s.requires_arc = true
    s.version = "0.0.10"

    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "Eido Goya" => "eido9oya@gmail.com" }
    s.homepage = "https://github.com/9oya/SSPager"

    s.source = { :git => "https://github.com/9oya/SSPager.git",
                 :tag => "#{s.version}" }

    s.framework = "UIKit"
    s.swift_version = "5.4"

    s.default_subspec = 'Core'
    s.subspec 'Core' do |core|
        core.source_files = "SSPager/*.{h,m,swift}"
    end
    s.subspec 'Rx' do |rx|
        rx.dependency 'SSPager/Core', '~> 0.0.10'
        rx.dependency 'RxSwift', '~> 6'
        rx.dependency 'RxCocoa', '~> 6'
        rx.source_files = "RxSSPager/*.{h,m,swift}"
    end
end
