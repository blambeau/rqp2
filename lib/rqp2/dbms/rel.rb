module RQP2
  class DBMS
    class Rel < self

      Error = Class.new(StandardError)

      Citrus.load File.expand_path('../rel/tutorial_d.citrus', __FILE__)

      def initialize(connspec)
        @connection = Connection.new(connspec)
        @connection.connect
      end

      def self.language
        'tutorial-d'
      end

      def self.connect(connspec)
        Rel.new(connspec)
      end

      def disconnect
        @connection.disconnect
      end

      def execute_ddl(ddl)
        @connection.execute_ddl(ddl)
      end

      def execute_dml(dml)
        @connection.execute_dml(dml)
      end

      def query(src)
        Alf::Relation(@connection.query(src))
      end

    end # class Rel
  end # class DBMS
end # module RQP2
require_relative 'rel/connection'
