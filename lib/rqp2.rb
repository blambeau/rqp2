require 'path'
require 'nokogiri'
require 'uuid'
require 'sequel'
require 'alf'
require 'citrus'
require 'logger'
require 'wlang'
require 'mail'

# The Relational Query Puzzle Platform
module RQP2

  # Simply checks that a path exists of raise an error
  def self._!(path)
    Path(path).tap do |p|
      raise "Missing #{p.basename}." unless p.exists?
    end
  end

  # Returns a configuration object for a particular environment
  def self.config_for(environment, basefile)
    unless (env = environment.split('/')).size >= 1
      raise ArgumentError, "Invalid environment"
    end
    unless basefile.exists?
      raise "Missing #{basefile.basename}"
    end

    env.reduce(basefile.load) do |config, e|
      cfg = config[e]
      raise "No config for environment `#{environment}`" unless cfg
      cfg
    end
  end

  def self.db_config_for(env)
    config_for(env, DATABASE_CONFIG_FILE)
  end

  # Version of the software component
  VERSION = "0.1.0"

  # Only use ruby's DateTime class and hide Time one
  Time = ::Sequel.datetime_class = ::DateTime

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  # Simple pointer to the assets folder
  ASSETS_FOLDER = _!(ROOT_FOLDER/'assets')

  # Folder containing configuration files
  CONFIG_FOLDER = _!(ROOT_FOLDER/'config')

  # Folder containing everything about the database
  DATABASE_FOLDER = _!(ROOT_FOLDER/'database')

  # Folder containing seed datasets
  SEEDS_FOLDER = _!(DATABASE_FOLDER/'seeds')

  # In what environment does the component run
  ENVIRONMENT = ENV['RQP2_ENV'] || ENV['RACK_ENV'] || "development"

  # Database configuration file, if any (e.g. no such one one heroku)
  DATABASE_CONFIG_FILE = CONFIG_FOLDER/'database.yml'

  # What database configuration to use
  DATABASE_CONFIG = ENV['DATABASE_URL'] || config_for(ENVIRONMENT, DATABASE_CONFIG_FILE)
  #DATABASE_CONFIG.merge!(loggers: [ Logger.new(STDOUT) ])

  # Sequel database object (for connection pooling)
  SEQUEL_DATABASE = ::Sequel.connect(DATABASE_CONFIG)

  # Alf database object
  ALF_DATABASE = ::Alf.database(SEQUEL_DATABASE, {
    schema_cache: true
  })

  # Test configuration file, if any
  TEST_CONFIG_FILE = CONFIG_FOLDER/'test.yml'

  # What test configuration to use
  TEST_CONFIG = config_for(ENVIRONMENT, TEST_CONFIG_FILE)

  # Mail configuration file, if any
  MAIL_CONFIG_FILE = CONFIG_FOLDER/'mail.yml'

  # What mail configuration to use
  MAIL_CONFIG = config_for(ENVIRONMENT, MAIL_CONFIG_FILE)

  # Configure the mail service
  Mail.defaults do
    delivery_method \
      MAIL_CONFIG.delete("delivery_method").to_sym,
      Alf::Support.symbolize_keys(MAIL_CONFIG)
  end

  # UUID
  UUID_GENERATOR = ::UUID.new

end # module RQP2
require_relative 'rqp2/submission'
require_relative 'rqp2/database'
require_relative 'rqp2/dbms'
require_relative 'rqp2/tester'
require_relative 'rqp2/reporter'
