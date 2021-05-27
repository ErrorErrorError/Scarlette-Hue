# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
workspace 'WLED Project.xcworkspace'
xcodeproj 'WLED Remote.xcodeproj'
xcodeproj 'Moya/Moya.xcodeproj'

def rx_swift
  pod 'RxSwift', '6.2.0'
end

def rx_cocoa
  pod 'RxCocoa', '6.2.0'
end

def alamofire
  pod 'Alamofire'
end

def rx_alamofire
  pod 'RxAlamofire'
end

def query_kit
  pod 'QueryKit'
end

def rx_data_source
  pod 'RxDataSources'
end

target 'WLED Remote' do
  # Comment the next line if you don't want to use dynamic frameworks
  xcodeproj 'WLED Remote.xcodeproj'
  use_frameworks!
  rx_swift
  rx_cocoa
  rx_data_source
  alamofire
  rx_alamofire
  query_kit
end

target 'ErrorErrorErrorUIKit' do
  xcodeproj 'WLED Remote.xcodeproj'
  use_frameworks!
  rx_swift
  rx_cocoa
end

target 'Moya' do
  xcodeproj 'Moya/Moya.xcodeproj'
  use_frameworks!
  alamofire
end

target 'RxMoya' do
  xcodeproj 'Moya/Moya.xcodeproj'
  use_frameworks!
  rx_swift
end
