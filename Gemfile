source "https://rubygems.org"

# Add these to fix Ruby 3.4 removed stdlibs
gem "abbrev"
gem "mutex_m"
gem "ostruct"
gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)