namespace :db do
  ROOT      = RQP2::ROOT_FOLDER
  DB_FOLDER = RQP2::DATABASE_FOLDER
  DB_CONFIG = RQP2::DATABASE_CONFIG
  SEQUEL_DB = RQP2::SEQUEL_DATABASE

  desc "Drops the database (USE WITH CARE)"
  task :drop do
    shell pg_cmd("dropdb #{DB_CONFIG['database']}"),
          pg_cmd("dropuser #{DB_CONFIG['user']}")
  end

  desc "Create an fresh new database (USE WITH CARE)"
  task :create => :drop do
    shell pg_cmd("createuser --no-createdb --no-createrole --no-superuser --no-password #{DB_CONFIG['user']}"),
          pg_cmd("createdb --owner=#{DB_CONFIG['user']} #{DB_CONFIG['database']}")
  end

  desc "Run migrations on the current database"
  task :migrate do
    Sequel.extension :migration
    Sequel::Migrator.apply(SEQUEL_DB, DB_FOLDER/"migrations")
  end

  desc "Seed the database (USE WITH CARE)"
  task :seed, :from do |t,args|
    RQP2::Database::Seeder.call(args[:from] || '2014')
  end

  desc "Rebuild the database (USE WITH CARE)"
  task :rebuild, :from do |t,args|
    RQP2::Database::Seeder.call(args[:from] || '2014')
  end
  task :rebuild => [ :create, :migrate ]

end
