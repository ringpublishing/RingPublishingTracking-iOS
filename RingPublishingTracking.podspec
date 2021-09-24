Pod::Spec.new do |s|
    s.name         = "RingPublishingTracking"
    s.version      = "0.1.0"

    s.summary      = "TBD"
    s.license      = { :type => 'Copyright. Ringier Axel Springer Polska', :file => 'LICENSE' }
    s.authors      = { "Adam Szeremeta" => "adam.szeremeta@ringieraxelspringer.pl" }

    s.homepage     = "https://github.com/ringpublishing/RingPublishingGDPR-iOS"
    s.source       = { :git => "https://github.com/ringpublishing/RingPublishingGDPR-iOS.git", :tag => s.version }

    s.platform = :ios, '11.0'
    s.ios.deployment_target = '11.0'

    s.static_framework = true
    s.requires_arc = true

    s.swift_version = '5.1'

    s.source_files = ['Sources/**/*.{swift}']
end
