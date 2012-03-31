require 'yaml'
require 'erb'
YETTINGS_PATH = "#{File.dirname(__FILE__)}/yettings"
require "#{YETTINGS_PATH}/railtie.rb"

module Yettings
  class UndefinedYetting < StandardError; end
  class << self
    def setup!
      find_ymls.each do |yml|
        create_yetting_class(yml)
      end
    end
  
    def find_ymls
      main_file = "#{Rails.root.to_s}/config/yetting.yml"
      yettings_main_file = File.exists?(main_file) ? [main_file] : []
      yettings_namespaced_files = Dir.glob("#{Rails.root.to_s}/config/yettings/**/*.yml")
      yettings_main_file.concat(yettings_namespaced_files)
    end
  
    def create_yetting_class(yml_file)
      hash = load_yml(yml_file)
      klass_name = File.basename(yml_file).gsub(".yml","").camelize
      klass_name = "#{klass_name}Yetting" unless klass_name=="Yetting"
      klass = Object.const_set(klass_name,Class.new)
      hash.each do |key,value|
        klass.define_singleton_method(key){ value }
      end
      klass.class_eval do
        def self.method_missing(method_id,*args)
          raise UndefinedYetting, "#{method_id} is not defined in #{self.to_s}"
        end
      end
    end
  
    def load_yml(yml_file)
      erb = ERB.new(File.read(yml_file)).result
      erb.present? ? YAML.load(erb).to_hash[Rails.env] : {}
    end
  end # class << self
end