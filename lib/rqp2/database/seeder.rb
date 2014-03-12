module RQP2
  module Database
    class Seeder

      def initialize(connection)
        @connection = connection
      end
      attr_reader :connection

      def self.call(from)
        ALF_DATABASE.connect do |conn|
          new(conn).call(from)
        end
      end

      def call(from)
        connection.in_transaction do
          folder = SEEDS_FOLDER/from

          # load metadata and install parent dataset if any
          metadata = (folder/"metadata.json").load
          if parent = metadata["inherits"]
            call(parent)
          end

          # load files in order
          files = folder.glob("*.json").reject{|f| f.basename.to_s =~ /^metadata/ }.sort
          names = files.map{|f|
            f.basename.rm_ext.to_s[/^\d+-(.*)/, 1].gsub(/-/, '_')
          }
          pairs = files.zip(names)

          # Truncate tables then fill them
          names.reverse.each do |name|
            connection.relvar(name).delete
          end
          pairs.each do |file, name|
            connection.relvar(name).affect(file.load)
          end
        end
      end

    end # class Seeder
  end # module Database
end # module RQP2
