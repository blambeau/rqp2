# RQP2 -- The Relational Query Puzzle Platform

An idea for a platform helping students and teachers of the Relational Model
mastering query languages such as **Tutorial D** and SQL.

## State of the project

The current repository is currently used at the University of Louvain for the
Databases course (formally LINGI2172) for auto-evaluating student submissions
of a practical missions.

More information can be found by contacting Bernard Lambeau.

## Installing

On a fresh git clone, with a decent ruby installation (i.e. including bundler):

1. Install dependencies

    ```
    bundle install --binstubs
    ```

2. Copy the config example files in `config/` and adapt them to your environment.

3. Make sure that you have both PostgreSQL server and database matching your
   configuration

   Two rake tasks `db:drop` and `db:create` exist you may need to adapt them a little
   bit to your environment. Otherwise simply create the database manually.

4. Migrate the PostgreSQL database schema and seed some puzzles

    ```
    bin/rake db:migrate
    bin/rake db:seed[2014]
    ```

    The seeds from 2014 are defined in `database/seeds`. Please contribute any new
    collection.

5. Make sure that you have both a Rel server and PostgreSQL database for the evaluation
   tester, as described in the `language` entry of the database.yml config file.

   (Here also, a `evaluator:install` rake task exists for PostgreSQL but might need
   adaptations)

   (for Rel, `java -jar Rel.jar -f/tmp/rel-database -D` should make it roughly)

## Using the plateform

### Getting some help

```
bin/rqp2 --help
bin/rqp2 help COMMAND
```

### Checking the validaty of a submission according to the XML schema

```
bin/rqp2 check assets/submission-example.xml
```

### Importing a submission

```
bin/rqp2 import --year=2014 assets/submission-example.xml
```

* Current year is used by default if not provided explictly
* Pass mutliple files to bulk import many submissions

### Running the tester

Make sure that both the PostgreSQL evaluation database and the Rel server exist. Then:

```
bin/rqp2 test
```

For now the submission to test against is the one from 'Bernard Lambeau'. Pull requests
are welcome to make this configurable.

### Making reports

```
bin/rqp2 --year=2014 report
```

By default, the command generates .html reports in `submissions/YEAR/`. It supports sending
email directly to students, but that options should certainly be used with much precaution.