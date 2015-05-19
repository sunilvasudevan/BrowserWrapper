# Description: Webdriver class for handling the Grid / Local execution
# Created by LZD643 on 3/19/2015.
# Bugs:
#         1. Unable to pick executable from different location
#         2. Need to add handle for executable browser location.
#
# License: Usage of custom framework is restricted to limited audience.
require 'active_model'
require 'watir-webdriver'
require 'selenium-webdriver'
require 'webdriver-user-agent'
require_relative 'sauce_driver'
require_relative 'automation_environment'

class WebDriver
    include ActiveModel::Validations

  attr_accessor :driver_object, :user_agent,:browser_switches

  validate :validate_driver

  # create the Webdriver object
  def initialize(options={})

    web_driver_properties = {
      :driver_object => nil,
      :user_agent =>   nil,
      :browser_switches =>%w[--disable-extensions]
    }.merge(options)

    self.driver_object = web_driver_properties[:driver_object]
    self.user_agent = web_driver_properties[:user_agent]
    self.browser_switches =web_driver_properties[:browser_switches]
  end

  # create the driver object based on the browser
  def get_webdriver_object(automation_env_obj)
    if automation_env_obj.execution_type =='remote'
      get_remote_webdriver_object(automation_env_obj)
    else
      get_local_webdriver_object(automation_env_obj)
    end
    # Check whether object has been created or not.
    if valid?
      puts ('===========================================================')
      puts ("Browser : #{automation_env_obj.browser_name} \n" )
      puts ("Implicit wait : #{automation_env_obj.implicit_wait} \n" )
      if automation_env_obj.browser_version.present?
        puts ("Browser Version : #{automation_env_obj.browser_version} \n" )
      end
      puts ("Execution Env: #{automation_env_obj.execution_type} \n" )
      puts ('===========================================================')
      self.driver_object.manage.window.maximize
      self.driver_object.switch_to.default_content
      return self.driver_object
    end
  end
  private
  #Getting the browser object for remote execution
  def get_remote_webdriver_object(automation_env_obj)
    caps = ''
    case automation_env_obj.browser_name.downcase
      when 'chrome'
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end

        caps['takesScreenshot'] = true
      when 'firefox'
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      when 'ie'||'internet explorer'||'iexplore'
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      when 'android'
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      when 'iphone'
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      when 'headless'
        caps = Selenium::WebDriver::Remote::Capabilities.htmlunitwithjs
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      when 'ipad'
        caps = Selenium::WebDriver::Remote::Capabilities.ipad
        caps[:trustAllSSLCertificates] = true
        caps['browserName'] = automation_env_obj.browser_name
        if automation_env_obj.browser_version.present?
          caps.version = automation_env_obj.browser_version
        end
        if automation_env_obj.platform.present?
          caps.platform = automation_env_obj.platform
        end
        caps['takesScreenshot'] = true
      else
        puts ('i am here')
        errors.add(:driver_object,'is invalid. Please check browser name & version')
    end
    self.driver_object = Selenium::WebDriver.for(:remote, :url => automation_env_obj.grid_url,
                                                 :desired_capabilities => caps)
  end
  # getting the browser object for local execution
  def get_local_webdriver_object(automation_env_obj)
    case automation_env_obj.browser_name
      when 'chrome'
        self.driver_object = Selenium::WebDriver.for :chrome
      when 'firefox'
        self.driver_object = Selenium::WebDriver.for :firefox
      when 'ie'
        self.driver_object = Selenium::WebDriver.for :internet_explorer
      when 'android'
        self.driver_object = Selenium::WebDriver.for :android
      when 'iphone'
        self.driver_object = Selenium::WebDriver.for :iphone
      when 'ipad'
        self.driver_object = Selenium::WebDriver.for :ipad
      when 'headless'
        self.driver_object = Selenium::WebDriver.for :htmlunitwithjs
      else
        errors.add(:driver_object,'cannot intialize because of unknown browser.')
    end
  end

  # after creation, this will validate whether the browser has been created or not.
  def validate_driver
    if driver_object.present? && driver_object ==nil
      errors.add(:driver_object,'is Nil. Please check the browser, version, Connection properties..')
    end
  end

end