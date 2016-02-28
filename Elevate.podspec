Pod::Spec.new do |s|
  s.name = 'Elevate'
  s.version = '1.3.0'
  s.summary = 'Elevate brings sanity and reliability to JSON parsing in Swift.'
  s.homepage = 'http://stash.nikedev.com/projects/SRG/repos/elevate/browse'
  s.license = { :type => 'COMMERCIAL', :text => 'Created and licensed by Nike. Copyright 2014-2015 Nike, Inc. All rights reserved.' }
  s.authors = { 'Eric Appel' => 'eric.appel@nike.com', 'Christian Noon' => 'christian.noon@nike.com' }

  s.source = { :git => 'ssh://git@stash.nikedev.com/srg/elevate.git', :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
end
