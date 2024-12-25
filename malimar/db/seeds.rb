# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[
  {
    name: "1 Month Web",
    cost: "7.99",
    period_in_monthes: 1,
    includes_roku_content: false,
    includes_web_content: true
  }
].each do |plan_data|
  Plan.where(plan_data).first_or_create!
end

admin_user = User::Local.where(login: ENV["ADMIN_LOGIN"]).first
unless admin_user.present?
  admin_user = User::Local::WithPassword.create!(
    email: ENV["SUPPORT_EMAIL"],
    login: ENV["ADMIN_LOGIN"],
    password: ENV["ADMIN_PASSWORD"]
  )
end

admin_user.subscription.add_time admin: 10.years unless admin_user.subscription.has_access_to? :admin
