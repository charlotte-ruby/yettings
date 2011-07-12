require 'rails'
require 'yettings'

module Yettings
  class Railtie < Rails::Railtie
    config.before_configuration do
      Yettings.setup!
    end
  end
end
