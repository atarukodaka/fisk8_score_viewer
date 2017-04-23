RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))

require 'capybara/cucumber'
require 'rspec/expectations'

##
# You can handle all padrino applications using instead:
#   Padrino.application
Capybara.app = ScoreViewer::App.tap { |app|  }
