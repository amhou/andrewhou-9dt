DB = Sequel.connect(
  :adapter => 'mysql2',
  :user => ENV['MYSQL_USER'],
  :host => 'mysql',
  :database => ENV['MYSQL_DATABASE'],
  :password => ENV['MYSQL_PASSWORD']
)
