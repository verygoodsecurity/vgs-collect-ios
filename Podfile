platform :ios, '10.0'

workspace 'VGSCollectSDK'

target 'VGSFramework' do
  use_frameworks!
  pod 'Alamofire', "4.9.1"

  target 'FrameworkTests' do
#    inherit! :search_paths
  end
end


# The workaround starts here !!!!!
targetWorkaround = "Pods-VGSFrameworkTests"

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts "#{target.name}"
    if target.name == targetWorkaround
      puts "Replacing!!!"
      
      puts `cp "./Pods/Target Support Files/Pods-VGSFramework/Pods-VGSFramework.debug.xcconfig" "./Pods/Target Support Files/Pods-VGSFrameworkTests/Pods-VGSFrameworkTests.debug.xcconfig"`
      puts `cp "./Pods/Target Support Files/Pods-VGSFramework/Pods-VGSFramework.release.xcconfig" "./Pods/Target Support Files/Pods-VGSFrameworkTests/Pods-VGSFrameworkTests.release.xcconfig"`
      
    end
  end
end

