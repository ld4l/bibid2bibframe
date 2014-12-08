class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer :bibid
      t.text :marcxml
      t.text :rdf

      t.timestamps
    end
  end
end
