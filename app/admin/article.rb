ActiveAdmin.register Article do
  actions  :index

  index do
    column :id
    column :name
    column :content
    actions
  end

  csv do
    column :created_at
    column :name
    column :id
    column :content
  end

 end
