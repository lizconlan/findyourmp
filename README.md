## Installation

clone the repository

create your database.yml file using the supplied example

  cp config/database.yml.example config/database.yml

run the rake tasks to create the database

  rake db:create:all
  rake db:migrate:reset RAILS_ENV=xxx

restore the data from a recent database dump or use the rake tasks to load the data from files (not included as part of the repository - to big, would infringe copyright, would be a job in its own right keeping this updated.)

### load constituency data

  rake fymp:constituencies RAILS_ENV=xxx

expects a TSV formatted file consisting of
  ID, constituency name
as `data/new_constituencies.txt`

### load the member data

  rake fymp:members RAILS_ENV=xxx

expects a TSV formatted file consisting of columns:
  constituency name<TAB>member name<TAB>member party<TAB>biography URL<TAB>contact (email or URL)<TAB>member website<TAB>member visible

Notes:
- Only the first three columns are required for basic linking in development.
- Set the last column (member visible) to True to ensure members appear on constituency pages in example data.
- Default file path is `data/FYMP_all.txt` (override with `file=...`).

### prepare the postcode data for loading

Creates postcodes.txt. If you already have a `data/postcodes.txt` that looks promising DO NOT RUN THIS STEP, otherwise go make a cup of tea; this bit isn't quick.

  rake fymp:parse RAILS_ENV=xxx source_file=xxx

expects the sort of file one would expect to pay ONS a recurring subscription fee to receive (plaintext version)

### load the postcode data

Definitely cup of tea time, consider renting a movie, maybe 2. Takes the simplified postcode data from `data/postcodes.txt` - still millions of records but just the bits we actually want from the massive file - and loads them into the database. Takes hours (on my MacBook Pro, I'm getting a 4 hour estimate).

File format for `data/postcodes.txt` (fixed-width):
- columns 0..6: postcode code (7 characters; pad with spaces if shorter, e.g. `W1A0AX` becomes `W1A0AX` with one trailing space)
- column 7: a single space
- columns 8..10: 3-character ONS constituency ID

Examples:
  SW1A1AA␠123
  W1A0AX␠␠123   (6-char code → two spaces before ONS ID)
  EH991S␠␠456   (6-char code → two spaces before ONS ID)

  rake fymp:populate RAILS_ENV=xx

### set up the postcode districts

Runs some SQL against the postcodes table in order to populate the postcode districts information. Reasonably fast.

  rake fymp:load_postcode_districts RAILS_ENV=xx
  

### set up us the constituency slugs

Invoke the power of the `friendly_id` gem to create nice url slugs for the constituencies

  rake friendly_id:make_slugs MODEL=Constituency RAILS_ENV=xx


## Sample data quick reload (Docker)

  docker compose exec app bash -lc 'bundle exec rake fymp:constituencies RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:members RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:populate RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:load_postcode_districts RAILS_ENV=development'

## Example data (committed)

Small example files live in `example-data/` and can be used for local development.

Copy them into `data/` (the app’s default data directory):

  mkdir -p data && cp example-data/* data/

Then reload:

  docker compose exec app bash -lc 'bundle exec rake fymp:constituencies RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:members RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:populate RAILS_ENV=development'
  docker compose exec app bash -lc 'bundle exec rake fymp:load_postcode_districts RAILS_ENV=development'

Notes
- Members can also be loaded directly from `example-data/FYMP_all.txt` via:

    docker compose exec app bash -lc 'bundle exec rake fymp:members RAILS_ENV=development file=example-data/FYMP_all.txt'

- Constituencies and postcodes use fixed default paths, so copying to `data/` is recommended.

## Maintenance notes (copied verbatim from original README, not tested)

To get the emergency server shutdown to work, you need to run the following...

  sudo visudo

...and add in the next 2 lines, substituting [SITE_CONTEXT_USER] with the actual user or group the site runs as

  Cmnd_Alias     APACHE = /etc/init.d/apache2 start, /etc/init.d/apache2 stop, /etc/init.d/apache2 restart, /etc/init.d/apache2 reload`
  [SITE_CONTEXT_USER] ALL=NOPASSWD: APACHE