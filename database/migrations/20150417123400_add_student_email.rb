Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE students
      ADD COLUMN email VARCHAR(255) NULL;
    SQL
  end
end
