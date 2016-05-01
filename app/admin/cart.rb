ActiveAdmin.register Cart do

  index do
    selectable_column
    column :user
    actions
  end

  filter :user 
end
