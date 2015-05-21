# Description: Main module thats needs to be included in any project.
#             Top layer that will give access to all the modules
# Created by Sunil on 3/12/2015.
# Bugs: No

require_relative 'automation_environment'
require_relative 'sauce_driver'
require_relative 'web_driver'
require 'yml_reader'

module BrowserWrapper
  @default_directory = '../../../config/browser_config'
  @env_config, @sauce_config = nil
  @yml_data = nil

  # Method will override the default path 'config/env_config.yml'
  def self.load_yml(file_name = 'browser_config')
    path  = File.expand_path("../../../config/#{file_name}.yml", __FILE__)
    @yml_data = YAML::load((File.new(path)))
  end

  # will open browser based on the command line arguments
  # Method will load arguments from yml file or will create a configuration
  # open the watir Webdriver instance
  def self.launch_watir_browser
    # code for not handled browsers
    load_env_variables
    browser_config_key = ENV['BROWSER'].to_s.downcase
    sauce_config_key = ENV['RUN'].to_s.downcase unless ENV['RUN'].nil?
    if @yml_data.present?
      read_configuration browser_config_key
      if sauce_config_key.present?
        read_configuration sauce_config_key
      end
      @browser = AutomationEnvironment.new(@env_config.to_h).get_watir_browser_instance
      raise('unable to create browser session, Check Configuration!!!') unless @browser
      return @browser
    end
  end

  # will open browser based on the command line arguments
  # Method will load arguments from yml file or will create a configuration
  # open the Selenium Webdriver instance
  def self.launch_selenium_browser
    # code for not handled browsers
    load_env_variables
    browser_config_key = ENV['BROWSER'].to_s.downcase
    sauce_config_key = ENV['RUN'].to_s.downcase unless ENV['RUN'].nil?
    if @yml_data.present?
      read_configuration key
      if sauce_config_key.present?
        read_configuration sauce_config_key
      end
      @browser = AutomationEnvironment.new(@env_config.to_h).get_browser_object
    end
  end

  private
  #
  def self.load_env_variables
    browser_details = ENV['RDEE_BROWSER'].split ','
    ENV['BROWSER'] = browser_details[0].to_s.downcase
    ENV['VERSION'] = browser_details[1] unless browser_details[1].nil?
    ENV['OS'] = browser_details[2] unless browser_details[1].nil?
  end

  def self.read_configuration(key)
    unless @env_config
      @env_config = @yml_data[key].to_h
      if ENV['BROWSER'].present?
        @env_config[:browser_name] =ENV['BROWSER']
      end
      if ENV['OS'].present?
        @env_config[:platform] =ENV['OS']
      end
      if ENV['VERSION'].present?
        @env_config[:browser_version] =ENV['VERSION']
      end
    else
      prep_data = @yml_data[key].to_h
      raise ArgumentError, "Undefined key #{key}" unless prep_data
      config_hash =  prep_data.merge(@env_config).clone
      @env_config = config_hash
    end
    raise ArgumentError, "Undefined key #{key}" unless @env_config
  end
end
