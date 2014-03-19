require 'path'
require 'nokogiri'
require 'uuid'
require 'sequel'
require 'alf'
require 'citrus'

# The Relational Query Puzzle Platform
module RQP2

  # Simply checks that a path exists of raise an error
  def self._!(path)
    Path(path).tap do |p|
      raise "Missing #{p.basename}." unless p.exists?
    end
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
  DATABASE_CONFIG = ENV['DATABASE_URL'] \
                 || (DATABASE_CONFIG_FILE.exists? && DATABASE_CONFIG_FILE.load[ENVIRONMENT]) \
                 || raise("Unable to find database configuration under `#{ENVIRONMENT}`")

  # Sequel database object (for connection pooling)
  SEQUEL_DATABASE = ::Sequel.connect(DATABASE_CONFIG)

  # Alf database object
  ALF_DATABASE = ::Alf.database(SEQUEL_DATABASE)

  # UUID
  UUID_GENERATOR = ::UUID.new

end # module RQP2
require_relative 'rqp2/submission'
require_relative 'rqp2/database'
