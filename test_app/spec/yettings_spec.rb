require 'spec_helper'

describe Yettings do
  YETTINGS_DIR = "#{Rails.root}/config/yettings"
  YETTING_FILE = "#{Rails.root}/config/yetting.yml"
  
  it "should load yettings in the rails app" do
    assert defined?(Yettings)
  end
  
  it "should find only default yml file if no others exist" do
    FileUtils.mv(YETTINGS_DIR,"#{YETTINGS_DIR}_tmp") if File.directory?(YETTINGS_DIR)
    Yettings.find_ymls.should eq ["#{Rails.root}/config/yetting.yml"]
    FileUtils.mv("#{YETTINGS_DIR}_tmp",YETTINGS_DIR) if File.directory?("#{YETTINGS_DIR}_tmp")
  end
  
  it "should find main and 2 yettings dir files" do
    Yettings.find_ymls.should eq ["#{Rails.root}/config/yetting.yml",
                                  "#{Rails.root}/config/yettings/hendrix.yml",
                                  "#{Rails.root}/config/yettings/jimi.yml"]
  end
  
  it "should find 2 yettings dir files if there is no main file" do
    FileUtils.mv("#{YETTING_FILE}","#{YETTING_FILE}_tmp") if File.exists?("#{YETTING_FILE}")
    Yettings.find_ymls.should eq ["#{Rails.root}/config/yettings/hendrix.yml",
                                  "#{Rails.root}/config/yettings/jimi.yml"]    
    FileUtils.mv("#{YETTING_FILE}_tmp","#{YETTING_FILE}") if File.exists?("#{YETTING_FILE}_tmp")
  end
  
  it "should load the yml and return hash" do
    Yettings.load_yml("#{YETTING_FILE}").should eq "yetting1"=>"what", "yetting2"=>999, "yetting3"=>"this is erb", "yetting4"=>["element1", "element2"]
  end
  
  it "should create the classes and class methods" do
    Yettings.create_yetting_class("#{YETTING_FILE}")
    Yetting.yetting1.should eq "what"
    Yetting.yetting2.should eq 999
    Yetting.yetting3.should eq "this is erb"
    Yetting.yetting4.should eq ["element1", "element2"]
  end
  
  it "should pass the integration test, since rails will run the initializer" do
    Yetting.yetting1.should eq "what"
    JimiYetting.yetting1.should eq "hendrix"
    HendrixYetting.yetting1.should eq "jimi"
  end
  
  it "should issue a warning for method_missing" do
    begin
      Yetting.whatwhat
    rescue => e
      e.should be_kind_of Yettings::UndefinedYetting
      e.message.should =~ /whatwhat is not defined in Yetting/
    end
  end
  
  it "should print the performance of setup method" do
    start = Time.now
    Yettings.setup! 
    puts "Load time for Yettings.setup! = #{Time.now - start} seconds"
  end
end