# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

def rx_swift
  pod 'RxSwift', '6.2.0'
end

def alamofire
  pod 'Alamofire', '~> 5.2'
end

def rx_cocoa
  pod 'RxCocoa', '6.2.0'
end

def query_kit
  pod 'QueryKit'
end

target 'WLED Remote' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  rx_swift
  rx_cocoa
  alamofire
  query_kit
end

target 'ErrorErrorErrorUIKit' do
  use_frameworks!
  rx_swift
  rx_cocoa
end

target 'WLEDKit' do
  use_frameworks!
  rx_swift
  rx_cocoa
  alamofire
  query_kit
end
