require_relative "00_tweaks"
ActiveAdmin.register_page "Reports" do
  menu priority: 2, parent: "Other"

  content title: "Reports" do
    transactions = Transaction.successful.in_period_from(5.month.ago.beginning_of_month)
    columns do
      column do
        panel "Monthly transactions" do
          aggregator = Aggregator::Data.new(transactions)
                                       .by_period(:month, "%b %Y")
                                       .get_total(:amount)

          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Month")
          data_table.new_column("number", "Sales")

          # Add Rows and Values
          data_table.add_rows(aggregator.data.to_a)
          option = {
            title: "Company Performance",
            height: 360,
            material: false
          }
          chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, option)

          panel "Chart", id: "transactions_chart" do
            render_chart(chart, "transactions_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "new / renew" do
          aggregator = Aggregator::Data.new(transactions)
                                       .by_period(:month, "%b %Y")
                                       .reject_negative(:amount)
                                       .split_by_user_renew
                                       .count

          states = %i[new renew]

          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Month")
          states.each do |state|
            data_table.new_column("number", state)
          end

          data = aggregator.data.map do |period_key, states_in_period|
            [period_key].tap do |line|
              states.each do |state|
                line << states_in_period.fetch(state, 0)
              end
            end
          end
          # Add Rows and Values
          data_table.add_rows(data)
          option = {
            title: "Amount of new subscribers vs renews per month",
            height: 360,
            material: false
          }
          chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, option)

          panel "Chart", id: "amount_per_new_renew_per_month_chart" do
            render_chart(chart, "amount_per_new_renew_per_month_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "7.99 new / renew" do
          aggregator = Aggregator::Data.new(transactions.where(amount: "7.99"))
                                       .by_period(:month, "%b %Y")
                                       .split_by_user_renew
                                       .count

          states = %i[new renew]

          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Month")
          states.each do |state|
            data_table.new_column("number", state)
          end

          data = aggregator.data.map do |period_key, states_in_period|
            [period_key].tap do |line|
              states.each do |state|
                line << states_in_period.fetch(state, 0)
              end
            end
          end
          # Add Rows and Values
          data_table.add_rows(data)
          option = {
            title: "Amount of 7.99 plan new subscribers vs renews per month",
            height: 360,
            material: false
          }
          chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, option)

          panel "Chart", id: "amount_7_99_per_new_renew_per_month_chart" do
            render_chart(chart, "amount_7_99_per_new_renew_per_month_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "7.99 Plans per country" do
          aggregator = Aggregator::Data.new(transactions.where(amount: "7.99"))
                                       .by_period(:month, "%b %Y")
                                       .split_by_country
                                       .count

          aggregated_data = aggregator.data.map do |month, country_counts|
            filtered, passed = country_counts.partition do |_country, count|
              count.to_i < 5
            end

            passed << ["Other", filtered.map(&:last).map(&:to_i).reduce(&:+)]
            [month, passed.to_h]
          end.to_h

          countries = aggregated_data.values.map(&:keys).flatten.uniq

          data_table = GoogleVisualr::DataTable.new
          data_table.new_column("string", "Month")

          countries.each do |country|
            data_table.new_column("number", country)
          end

          data = aggregated_data.map do |period_key, period_plans|
            [period_key].tap do |line|
              countries.each do |country|
                line << period_plans.fetch(country, 0)
              end
            end
          end

          data_table.add_rows(data)
          option = {
            title: "7.99 plans per country",
            height: 2000,
            material: false
          }
          chart = GoogleVisualr::Interactive::BarChart.new(data_table, option)

          panel "Chart", id: "7_99_per_country_chart" do
            render_chart(chart, "7_99_per_country_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "Plans per month" do
          aggregator = Aggregator::Data.new(transactions)
                                       .by_period(:month, "%b %Y")
                                       .split_by(:amount, in_delta: 1, threshold_name: "Refunds") { |amount| amount < 0 }
                                       .count

          plans = aggregator.data.values.map(&:keys).flatten.uniq.sort_by { |plan| plan.is_a?(String) ? 0 : plan }

          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Month")
          plans.each do |plan|
            data_table.new_column("number", plan)
          end

          data = aggregator.data.map do |period_key, period_plans|
            [period_key].tap do |line|
              plans.each do |plan|
                line << period_plans.fetch(plan, 0)
              end
            end
          end
          # Add Rows and Values
          data_table.add_rows(data)
          option = {
            title: "Transactions per month",
            height: 2000,
            material: false
          }
          chart = GoogleVisualr::Interactive::BarChart.new(data_table, option)

          panel "Chart", id: "plans_per_month_chart" do
            render_chart(chart, "plans_per_month_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "Revenue per plan" do
          aggregator = Aggregator::Data.new(transactions)
                                       .by_period(:month, "%b %Y")
                                       .reject_negative(:amount)
                                       .split_by(:amount, in_delta: 1)
                                       .get_total(:amount)

          plans = aggregator.data.values.map(&:keys).flatten.uniq.sort_by { |plan| plan.is_a?(String) ? 0 : plan }

          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Month")
          plans.each do |plan|
            data_table.new_column("number", plan)
          end

          data = aggregator.data.map do |period_key, period_plans|
            [period_key].tap do |line|
              plans.each do |plan|
                line << period_plans.fetch(plan, 0)
              end
            end
          end
          # Add Rows and Values
          data_table.add_rows(data)
          option = {
            title: "Revenue per plan per month",
            height: 2000,
            material: false
          }
          chart = GoogleVisualr::Interactive::BarChart.new(data_table, option)

          panel "Chart", id: "revenue_per_plan_per_month_chart" do
            render_chart(chart, "revenue_per_plan_per_month_chart")
          end
        end
      end
    end

    columns do
      column do
        panel "Current user accounts" do
          data_table = GoogleVisualr::DataTable.new
          # Add Column Headers
          data_table.new_column("string", "Subscription")
          data_table.new_column("number", "Number of users")

          expire_soon_count = User::Local.expire_soon.count
          # Add Rows and Values
          data_table.add_rows([
                                ["Premium", User::Local.premium.count - expire_soon_count],
                                ["Expire soon", expire_soon_count],
                                ["Free", User::Local.free.count]
                              ])
          option = {
            title: "User Subscriptions",
            height: 350,
            pie_hole: 0.4,
            material: false
          }
          chart = GoogleVisualr::Interactive::PieChart.new(data_table, option)

          panel "Chart", id: "user_accounts_chart" do
            render_chart(chart, "user_accounts_chart")
          end
        end
      end
    end
  end # content
end
