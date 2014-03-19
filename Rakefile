$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'rqp2'

def pg_cmd(cmd)
  "#{cmd}"
end

def shell(*cmds)
  cmd = cmds.join("\n")
  puts cmd
  system cmd
end

#
# Install all tasks found in tasks folder
#
# See .rake files there for complete documentation.
#
Dir["tasks/*.rake"].each do |taskfile|
  begin
    load taskfile
  rescue LoadError
    # possibly due to environment (e.g. no test on heroku)
  end
end

# We run tests by default
task :default => :test
