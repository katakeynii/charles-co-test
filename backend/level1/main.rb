require 'json'
require 'date'
require '../helpers/helper.rb'
def main
  begin
    rentals = load_data('data/input.json')
    data_result = {rentals: rentals.map {|rent| rent.to_static_price} }
    File.open("data/output.json", "w") { |f| f.write data_result.to_json }
  rescue Errno::ENOENT => e
    puts "File or directory not found", e
    exit -1
  end
end


main()