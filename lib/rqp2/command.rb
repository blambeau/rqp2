require 'rqp2'
module RQP2
  #
  # RQP2 - The Relational Query Puzzle Platform
  #
  # SYNOPSIS
  #   rqp2 [--version] [--help] COMMAND [cmd opts] ARGS...
  #
  # OPTIONS
  # #{summarized_options}
  #
  # COMMANDS
  # #{summarized_subcommands}
  #
  # See 'rqp2 help COMMAND' for more information about a specific command.
  #
  class Command < Quickl::Delegator(__FILE__, __LINE__)

    # Install options
    options do |opt|

      # Show the help and exit
      opt.on_tail("--help", "Show help") do
        raise Quickl::Help
      end

      # Show version and exit
      opt.on_tail("--version", "Show version") do
        raise Quickl::Exit, "rqp2 #{VERSION} (c) 2014, The University of Louvain"
      end

    end

  end # class Command
end # module RQP2
require_relative "command/help"
require_relative "command/check"
require_relative "command/import"
require_relative "command/test"
