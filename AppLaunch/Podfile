# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AppLaunch' do
    use_frameworks!
    platform :ios, '9.0'
    pod 'BMSCore', '~> 2.0'
    pod 'SwiftyJSON'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
