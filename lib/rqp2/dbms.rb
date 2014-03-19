require_relative 'dbms/sql'
require_relative 'dbms/rel'
module RQP2
  class DBMS

    def self.postgres(connspec)
      SQL.new(connspec)
    end

    def self.rel(connspec)
      Rel.new(connspec)
    end

  end # class DBMS
end # module RQP2
