Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE submissions
      ADD COLUMN year INTEGER NOT NULL DEFAULT 2015 CHECK (year > 2000 AND year < 2030);
    SQL
  end
end
