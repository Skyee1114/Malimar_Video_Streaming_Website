require_relative "00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register Plan do
    menu priority: 0, parent: "Other"
    actions :all

    controller do
      def permitted_params
        params.permit!
      end
    end

    index do
      selectable_column
      column :name
      column :cost
      column :period_in_monthes
      column :includes_web_content
      column :includes_roku_content

      actions except: [:edit]
    end

    show do
      panel "Details" do
        attributes_table_for resource do
          Plan.column_names.each do |column_name|
            row column_name.to_sym unless %w[id created_at updated_at].include? column_name
          end
        end
      end

      panel "Audit data" do
        attributes_table_for(resource) do
          row :created_at
          row :updated_at
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end
  end
end
