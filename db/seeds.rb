# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(email: "yuna@0v0.cn",
             password:             "zxc123",
             password_confirmation: "zxc123")

5.times do |n|
  email = "cat-#{n+1}@0v0.cn"
  password = "password"
  user = User.create!(email: email,
                      password:             password,
                      password_confirmation: password)

  recipient_id = n+2
  contact = Contact.create!(sender_id: 1,
                            recipient_id: recipient_id)


  contact.messages.create!(content: "你好，欢迎你注册MiniCat。")
end
