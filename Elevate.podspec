Pod::Spec.new do |s|
  s.name = 'Elevate'
  s.version = '2.0.0'
  s.summary = 'Elevate is a JSON parsing framework that leverages Swift to make parsing simple, reliable and composable.'
  s.homepage = 'https://github.com/Nike-Inc/Elevate'
  s.license = 'MIT'
  s.authors = { 'Eric Appel' => 'eric.appel@nike.com', 'Christian Noon' => 'christian.noon@nike.com' }

  s.source = { :git => 'https://github.com/Nike-Inc/Elevate.git', :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end
