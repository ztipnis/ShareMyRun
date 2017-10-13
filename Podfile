# Uncomment this line to define a global platform for your project
platform :ios, '8.1'
# Uncomment this line if you're using Swift
#use_frameworks!

pod 'Ensembles', '~> 1.0'
pod 'FBSDKLoginKit'

pod 'Fabric'
pod 'Crashlytics'

target 'ShareMyRun' do


end

target 'ShareMyRunTests' do

end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end