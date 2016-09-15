class CreateAdditionalCosts < ActiveRecord::Migration
  def change
    create_table :additional_costs do |t|

      t.string :name

      t.float :cost

      t.integer :issue_id


    end

  end
end
