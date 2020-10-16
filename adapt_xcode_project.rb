#!/usr/bin/env ruby

require 'xcodeproj'
require 'yaml'

project_path = './ios/Runner.xcodeproj.orig'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first

target.build_configurations.each do |config|
  puts config.name
  config.build_settings['CODE_SIGN_IDENTITY']             = 'iPhone Developer'
  #config.build_settings['CODE_SIGN_STYLE']                = 'Manual'
  # for the DEVELOPMENT_TEAM value look at right top at https://developer.apple.com/account/resources/certificates/list
  config.build_settings['DEVELOPMENT_TEAM']               = 'AG8GUGCAKG'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']      = 'felix.alec.aloy'
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'felix alec flutterDemoB ios_app_development 1602828396'
end

project.save('./ios/Runner.xcodeproj')
