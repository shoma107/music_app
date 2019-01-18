require 'bundler/setup'
Bundler.require

if development?
    ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name,
    presence: true,
    format: { with: /\A\w+\z/ }
  validates :password,
    length: { in: 5..10 }
  has_many :tasks
end

class Task < ActiveRecord::Base
  validates :title,
   presence: true
  belongs_to :User
end