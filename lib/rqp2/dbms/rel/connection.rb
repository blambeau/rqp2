require 'socket'
module RQP2
  class DBMS
    class Rel
      class Connection

        def initialize(connspec = {})
          @host   = connspec['host'] || 'localhost'
          @port   = connspec['port'] || '5514'
          @socket = nil
        end
        attr_reader :host, :port, :socket

        def connect
          raise "Already connected" if @socket
          @socket = TCPSocket.open(host, port)
          read_response
        end

        def disconnect
          raise "Not connected" unless @socket
          @socket.close
        end

        def execute(ddl)
          write_and_flush('X', ddl)
          read_response.tap{|res|
            raise Rel::Error, res unless res.strip =~ /Ok.$/
          }
          true
        end
        alias :execute_ddl :execute
        alias :execute_dml :execute

        def query(src)
          write_and_flush('E', src)
          Grammar.parse(read_response, root: "literal").value
        end

      private

        def write_and_flush(kind, cmd)
          @socket.puts("#{kind}\n")
          @socket.puts(cmd)
          @socket.puts("<EOT>")
          @socket.flush
        end

        def read_response
          res = ""
          while (s = @socket.gets)
            break if s.strip == '<EOT>'
            res << s
          end
          res
        end

      end # class Connection
    end # class Rel
  end # class DBMS
end # module RQP2
