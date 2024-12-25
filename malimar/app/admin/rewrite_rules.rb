require_relative "00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register RewriteRule do
    menu priority: 6, parent: "Other"
    config.sort_order = "created_at_desc"
    actions :all

    controller do
      def permitted_params
        params.permit!
      end
    end

    scope :all, default: true
    scope :url

    filter :from_cont, as: :string
    filter :to_cont, as: :string
    filter :created_at

    index do
      selectable_column
      column :subject do |resource|
        status_tag resource.subject
      end

      column :from
      column :to
      column :date, sortable: :created_at do |resource|
        resource.created_at.to_formatted_s :short
      end

      actions
    end

    show do
      columns do
        column do
          panel "Rule" do
            attributes_table_for resource do
              rows :subject, :from, :to
            end
          end

          panel "Audit data" do
            attributes_table_for resource do
              row :created_at
              row :updated_at
            end
          end
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end

    form do |_f|
      semantic_errors
      inputs do
        input :subject, as: :select, collection: resource.class.subjects.keys, include_blank: false

        resource.class.column_names.each do |column_name|
          input column_name.to_sym unless %w[id subject created_at updated_at].include? column_name
        end
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
