#
# Be sure to run `pod lib lint Empyr.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Empyr'
  s.version          = '0.1.0'
  s.summary          = 'Empyr: A foundation for card link offer platforms.'

  s.description      = <<-DESC
Empyr is a full-stack card linked offer platform that enables companies to bring card linked offers to consumers and businesses.
                       DESC

  s.homepage         = 'https://www.empyr.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Empyr' => 'developer@empyr.com' }
  s.source           = { :git => 'https://github.com/EmpyrNetwork/empyr_ios_swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'
  
  s.default_subspecs = %w[Core]
  
  s.subspec "Core" do |s|
	  s.source_files = "EmpyrCore/**/*"
  end
  
  s.subspec "PPO" do |s|
	  s.source_files = "EmpyrPPO/**/*"
	  s.dependency "Empyr/Core"
	  s.dependency "PlotPlugin", "= 2.1.0-beta2"
  end
  
  s.subspec "Tracker" do |s|
	  s.source_files = "EmpyrTracker/**/*"
	  s.dependency "Empyr/Core"
  end
  
  # s.resource_bundles = {
  #   'Empyr' => ['Empyr/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
end
