class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets, &:timestamps
  end
end
