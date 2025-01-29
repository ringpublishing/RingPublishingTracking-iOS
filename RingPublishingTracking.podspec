Pod::Spec.new do |s|
    s.name         = "RingPublishingTracking"
    s.version      = "1.8.1"

    s.summary      = "SDK used to report events from mobile application"
    s.license      = { :type => 'Copyright. Ringier Axel Springer Polska', :file => 'LICENSE' }
    s.authors      = { "Adam Szeremeta" => "adam.szeremeta@ringieraxelspringer.pl", "Artur Rymarz" => "Artur.Rymarz@ringieraxelspringer.pl" }

    s.homepage     = "https://github.com/ringpublishing/RingPublishingTracking-iOS"
    s.source       = { :git => "https://github.com/ringpublishing/RingPublishingTracking-iOS", :tag => s.version }

    s.platform = :ios, '11.0'
    s.ios.deployment_target = '11.0'

    s.static_framework = true
    s.requires_arc = true

    s.swift_version = '5.1'

    s.source_files = ['Sources/**/*.{swift}']
end
