class AddLogoToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :logo, :string
  end
end
