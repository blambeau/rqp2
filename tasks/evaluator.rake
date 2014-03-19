namespace :evaluator do

  def evaluator_config
    RQP2.db_config_for('evaluator/sql')
  end

  desc "Uninstall the evaluator"
  task :uninstall do
    shell pg_cmd("dropdb #{evaluator_config['database']}"),
          pg_cmd("dropuser #{evaluator_config['user']}")
  end

  desc "Install the evaluator"
  task :install => :uninstall do
    shell pg_cmd("createuser --no-createdb --no-createrole --no-superuser --no-password #{evaluator_config['user']}"),
          pg_cmd("createdb --owner=#{evaluator_config['user']} #{evaluator_config['database']}")
  end

end