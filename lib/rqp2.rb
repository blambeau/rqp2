require 'path'
require 'nokogiri'

# The Relational Query Puzzle Platform
module RQP2

  ROOT_FOLDER = Path.dir.parent

  ASSETS_FOLDER = ROOT_FOLDER/'assets'

end # module RQP2
require_relative 'rqp2/submission'
