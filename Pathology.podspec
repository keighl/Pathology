Pod::Spec.new do |s|
  s.name = 'Pathology'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'A library for encoding/decoding CGPath data'
  s.homepage = 'https://github.com/keighl/Pathology'
  s.authors = { 'keighl' => 'keighl@keighl.com' }
  s.source = { :git => 'https://github.com/keighl/Pathology.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.source_files = 'Pathology/*.swift'
  s.requires_arc = true
end