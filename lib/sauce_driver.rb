# Description: Class for Handling the Sauce Lab connection
# Created by LZD643 on 3/19/2015.
# Bugs:

require 'active_model'
require 'date'

class SauceDriver
  include ActiveModel::Validations

  attr_accessor :sauce_username, :sauce_api_key, :sauce_lab_url, :sauce_driver, :sauce_tunnel, :proxy_url,
                :build_name

  validate :validate_username, :validate_api_key, :validate_sauce_url

  #set up
  def initialize(options={})
    sauce_properties ={
        :sauce_username => nil,
        :sauce_api_key => nil,
        :sauce_lab_url => 'ondemand.saucelabs.com:80/wd/hub',
        :sauce_tunnel =>'',
        :proxy_url => '',
        :build_name =>''
    }
    options.each do |key, value|
      if sauce_properties.has_key?(key)
        sauce_properties[key] = value
      end
    end

    self.sauce_username   = sauce_properties[:sauce_username].to_s
    self.sauce_tunnel     = sauce_properties[:sauce_tunnel].to_s
    self.build_name       = sauce_properties[:build_name].to_s
    self.sauce_api_key    = sauce_properties[:sauce_api_key].to_s
    self.sauce_lab_url    = sauce_properties[:sauce_lab_url].to_s
    self.proxy_url        = sauce_properties[:proxy_url].to_s
    puts("Sauce Parameters are #{sauce_properties}")

    time = DateTime.now
# custom build name format
    temp_name = "#{self.build_name}[#{time.month}/#{time.day}/#{time.year}][#{time.hour}:#{time.min}:#{time.sec}]"
    self.build_name = temp_name
    if self.proxy_url.present?
      ENV['HTTP_PROXY'] = self.proxy_url
    end
  end

  #Method will connect the sauce labs using the details
  def sauce_connect(env_obj)
    #control flow with negative validation
    if !valid?
      abort(errors.full_messages)
    end
    caps = nil
    self.build_name = "#{build_name} - [ #{env_obj.browser_name} ] "
    server_url=''
    case env_obj.browser_name
      when 'chrome'
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps[:name] = self.build_name
        caps['parent-tunnel'] = self.sauce_tunnel
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version.to_i
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end
        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"
      when 'firefox'
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps[:name] = self.build_name
        caps['parent-tunnel'] = self.sauce_tunnel
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end

        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"
      when 'ie'
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps[:name] = self.build_name
        caps['parent-tunnel'] = self.sauce_tunnel
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end
        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"
      when 'android'
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps[:name] = self.build_name
        if !sauce_tunnel.nil?
          caps['parent-tunnel'] = self.sauce_tunnel
        end
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end
        caps['deviceName'] = 'Samsung Galaxy S3 Emulator'
        caps['device-orientation'] = 'portrait'

        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"

      when 'iphone'
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        caps[:name] = self.build_name
        caps['parent-tunnel'] = self.sauce_tunnel
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end
        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"

      when 'ipad'
        caps = Selenium::WebDriver::Remote::Capabilities.ipad
        caps[:name] = self.build_name
        caps['parent-tunnel'] = self.sauce_tunnel
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = env_obj.browser_name
        if !env_obj.browser_version.nil?
          caps.version = env_obj.browser_version.to_i
        end
        if !env_obj.platform.nil?
          caps.platform = env_obj.platform
        end
        server_url = "http://#{self.sauce_username}:#{self.sauce_api_key}@#{sauce_lab_url}"

      else
        errors.add(:driver_object,'is invalid. Please check browser name & version')
    end


    puts ('               Sauce Lab Configuration                     ')
    puts ('===========================================================')
    puts ("Build Name                       :#{self.build_name}")
    puts ("Browser Name                     :#{env_obj.browser_name}")
    puts ("Browser Version                  :#{env_obj.browser_version}")
    puts ("Tunnel                           :#{self.sauce_tunnel}")
    puts ("OS Platform                      :#{env_obj.platform}")
    puts ("User Name                        :#{self.sauce_username}")
    puts ('===========================================================')
    begin
      self.sauce_driver = Selenium::WebDriver.for(:remote, :desired_capabilities => caps,
                                                  :url => server_url)
    rescue exception
      puts('===================================================')
      puts('Unable to connect to Sauce Lab tunnel')
      abort(exception.to_s)
    end

    return self.sauce_driver
  end

  private
  #Method defined  for validating the user name
  def validate_username
    puts "User name is #{sauce_username}"
    if !sauce_username.present? || sauce_username.length < 1
      errors.add(:sauce_username, 'is not valid. please check!!!')
    end
  end

  #method defined for validating the Api Key
  def validate_api_key
    if !sauce_api_key.present? || sauce_api_key.length < 1
      errors.add(:sauce_api_key, 'is not valid. please check!!!')
    end
  end

  #Method defined for validating the Sauce URL
  def validate_sauce_url
    if !sauce_lab_url.present? || sauce_lab_url.length < 1
      errors.add(:sauce_lab_url, 'is not valid. please check!!!')
    end
  end

end