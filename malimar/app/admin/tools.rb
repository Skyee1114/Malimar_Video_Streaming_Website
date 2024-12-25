# frozen_string_literal: true

require_relative "00_tweaks"
ActiveAdmin.register_page "Tools" do
  menu priority: 1, parent: "Other"

  content title: "Tools" do
    columns do
      column do
        panel "Cache" do
          button_to "Clear cache", admin_tools_clear_cache_path, method: :post
        end
      end

      column do
        panel "Bans" do
          button_to "Clear all bans", admin_tools_clear_all_bans_path, method: :post
        end

        panel "Manually ban an IP" do
          semantic_form_for :range, url: admin_tools_ban_ip_path do |f|
            f.input :ip, as: :string, label: "IP to ban "
          end
        end

        panel "Currently banned" do
          Rack::Attack::PERMANENT_BANS_STORE.smembers("blocklist").join(",\n")
        end
      end
    end
  end # content

  page_action :clear_cache, method: :post do
    Rails.cache.clear
    flash[:notice] = "Cache cleared"
    redirect_to admin_tools_path
  end

  page_action :clear_all_bans, method: :post do
    Rack::Attack.cache.store.flushdb
    Rack::Attack::PERMANENT_BANS_STORE.flushdb
    flash[:notice] = "Bans cleared"
    redirect_to admin_tools_path
  end

  page_action :ban_ip, method: :post do
    ip = params.dig(:range, :ip)
    Rack::Attack::PERMANENT_BANS_STORE.sadd :blocklist, ip
    flash[:notice] = "Banned IP: #{ip}"
    redirect_to admin_tools_path
  end
end
