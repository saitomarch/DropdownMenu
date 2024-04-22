Pod::Spec.new do |spec|
  spec.name         = "PFDropdownMenu"
  spec.version      = "0.4.0"
  spec.summary      = "Dropdown Menu for iOS"
  spec.homepage     = "https://github.com/saitomarch/DropdownMenu"
  spec.license      = "MIT"
  spec.author             = { "SAITO Tomomi" => "t-saito@project-flora.net" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/saitomarch/DropdownMenu.git", :tag => "v#{spec.version}" }
  spec.source_files  = "DropdownMenu/*.swift"
  spec.swift_versions = "5.0"
end
