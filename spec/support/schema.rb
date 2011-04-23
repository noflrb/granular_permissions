ActiveRecord::Schema.define :version => 0 do
  create_table 'vehicles', :force => true do |t|
    t.string :name
    t.string :tag
    t.integer :odometer
  end
end
