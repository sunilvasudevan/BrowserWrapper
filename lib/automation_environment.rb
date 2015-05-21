# Description:
#              Wrapper class for Web driver class and Sauce Driver class. Browser creation
#              starts from here
# Created by Sunil on 3/12/2015.
# Bugs: Known bugs

require_relative 'sauce_driver'
require 'active_model'
require 'watir-webdriver'
require 'selenium-webdriver'
require_relative 'web_driver'
require 'webdriver-user-agent'

class AutomationEnvironment
  include ActiveModel::Validations

  attr_accessor :browser_name, :browser_version, :implicit_wait,:execution_type,:grid_url,:platform,:sauce_driver,
                :web_driver,:browser_obj

  validate :validate_browser, :validate_version, :validate_wait


  # Automation Environment set up happens here
  def initialize(env_config={},sauce_connect=false)
    connection_parameters = {
        :browser_name => 'chrome',
        :browser_version => nil,
        :implicit_wait => 30,
        :execution_type => 'local',
        :grid_url =>nil,
        :platform =>nil
    }#.merge(env_config)
    env_config.each do |key, value|
      if connection_parameters.has_key?(key)
        connection_parameters[key] = value
      end
    end
    puts ('            Initializing automation test environment       ')
    puts ('===========================================================')

    # Assign the parameters individually to class variables
    self.browser_name     = connection_parameters[:browser_name].to_s
    self.browser_version  = connection_parameters[:browser_version]
    self.implicit_wait    = connection_parameters[:implicit_wait]
    self.execution_type   = connection_parameters[:execution_type].to_s
    self.grid_url         = connection_parameters[:grid_url].to_s
    self.platform         = connection_parameters[:platform]

    if env_config[:sauce_username].present?
      sauce_connect = true
    end

   # puts("connection parameters are #{env_config} And Sauce Connect is #{sauce_connect}")
    if valid?
      if sauce_connect
        self.sauce_driver = SauceDriver.new(env_config)
        self.browser_obj= self.sauce_driver.sauce_connect(self)
      else
        self.web_driver = WebDriver.new(env_config)
        self.browser_obj= web_driver.get_webdriver_object(self)
      end
    end
  end

  # will return the selenium Webdriver Browser instance
  def get_browser_object
    self.browser_obj
  end

  # If you are using watir webdriver, this method will return the watir object
  def get_watir_browser_instance
    browser = Watir::Browser.new browser_obj
    browser
  end

  :private
  # this will validate whether the browser name provided is valid or not.
  def validate_browser
    if !browser_name.present? || !(browser_name.to_s.downcase =='chrome' || browser_name.to_s.downcase =='firefox' ||
        browser_name.to_s.downcase =='ie'||browser_name.to_s.downcase =='headless'||
        browser_name.to_s.downcase =='android')
      errors.add(:browser_name, 'is invalid. Possible values are [chrome | Firefox | ie etc ]')
    end
  end

  # this will validate the browser version provided.
  def validate_version
    if browser_version.present? && browser_version.to_i < 0
      errors.add(:browser_version, 'is invalid. Possible values are >0')
    end
  end

  # method to validate the wait parameter
  def validate_wait
    if implicit_wait.present? && implicit_wait.to_i < 0
      errors.add(:implicit_wait, 'is invalid. Possible values are >0')
    end
  end
end