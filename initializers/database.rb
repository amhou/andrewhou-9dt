DB = Sequel.connect(
  :adapter => 'mysql',
  :user => ENV['MYSQL_USER'],
  :host => 'mysql',
  :database => ENV['MYSQL_DATABASE'],
  :password => ENV['MYSQL_PASSWORD']
)
