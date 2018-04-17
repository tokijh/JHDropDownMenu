Pod::Spec.new do |s|
  s.name             = 'JHDropDownMenu'
  s.version          = '1.0.0'
  s.swift_version    = '4.0'
  s.summary          = 'DropDown menu in UIView by extension'
  s.description      = 'Dropdown menu in UIView by extension'
  s.homepage         = 'https://github.com/tokijh/JHDropDownMenu'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tokijh' => 'tokijh@naver.com' }
  s.source           = { :git => 'https://github.com/tokijh/JHDropDownMenu.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'JHDropDownMenu/*swift'
end

