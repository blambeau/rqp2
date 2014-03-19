Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE puzzles
        ADD COLUMN exemplar VARCHAR(30) NULL REFERENCES exemplars (exemplar);
      UPDATE puzzles SET exemplar = 'suppliers-and-parts';
      ALTER TABLE puzzles
        ALTER COLUMN exemplar SET NOT NULL;
    SQL
  end
  down do
    run <<-SQL
      ALTER TABLE puzzles
        DROP COLUMN exemplar;
    SQL
  end
end