Pod::Spec.new do |s|
  s.name = 'Elevate'
  s.version = '0.0.1'
  s.summary = 'TODO'
  s.homepage = 'http://stash.nikedev.com/projects/BMD/repos/willow/browse'
  s.license = { :type => 'COMMERCIAL', :text => 'Created and licensed by Nike. Copyright 2015 Nike, Inc. All rights reserved.' }
  s.authors = { 'Eric Appel' => 'eric.appel@gmail.com', 'Christian Noon' => 'christian.noon@gmail.com' }

  s.source = { :git => 'ssh://git@stash.nikedev.com/srg/elevate.git', :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
end
