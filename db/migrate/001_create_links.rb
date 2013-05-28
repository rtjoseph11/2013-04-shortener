# Put your database migration here!
#
# Each one needs to be named correctly:
# timestamp_[action]_[class]
#
# and once a migration is run, a new one must
# be created with a later timestamp.

class CreateLinks < ActiveRecord::Migration
  def up
    create_table :links do |t|
      t.string :rawUrl, :null => false
      t.string :shortenedUrl, :null => false
      t.timestamps
    end
    execute <<-SQL
      CREATE INDEX uix_rawUrl ON links(rawUrl);
    SQL
  end
  def down
    drop_table :links
  end
end