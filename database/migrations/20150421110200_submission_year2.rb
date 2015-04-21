Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE submissions RENAME COLUMN year TO submission_year;
    SQL
  end
end
