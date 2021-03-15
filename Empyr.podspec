Pod::Spec.new do |s|
  s.name             = 'Empyr'
  s.version          = '0.9.3'
  s.summary          = 'Empyr: A foundation for card link offer platforms.'

  s.description      = <<-DESC
Empyr is a full-stack card linked offer platform that enables companies to bring card linked offers to consumers and businesses.
                       DESC

  s.homepage         = 'https://www.empyr.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Empyr' => 'developer@empyr.com' }
  s.source           = { :git => 'https://github.com/EmpyrNetwork/empyr_ios_swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  
  s.default_subspecs = %w[Core]
  
  s.subspec "Core" do |s|
	  s.source_files = "EmpyrCore/**/*"
  end
  
  s.subspec "PPO" do |s|
	  s.source_files = "EmpyrPPO/**/*"
	  s.dependency "Empyr/Core"
	  s.dependency "PlotPlugin", "= 2.1.0-beta2"
	  s.frameworks = "PlotProjects"
	  s.user_target_xcconfig = {
		'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
	  }
	  s.pod_target_xcconfig = {
		'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
	  }
  end
  
  s.subspec "Tracker" do |s|
	  s.source_files = "EmpyrTracker/**/*"
	  s.dependency "Empyr/Core"
  end
  
end
