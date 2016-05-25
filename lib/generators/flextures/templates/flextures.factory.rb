# Flextures::Factory.define :users do |f|
#   f.password = "hogehoge"
#   f
# end

# Flextures::DumpFilter.define :users, {
#   :encrypted_password => lambda { |v| Base64.encode64(v) }
# }
