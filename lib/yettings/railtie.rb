require 'rails'
require 'yettings'

module Yettings
  class Railtie < Rails::Railtie
    initializer "yettings.setup!" do
      Yettings.setup!
    end
  end
end