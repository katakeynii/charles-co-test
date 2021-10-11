# require "./car.rb"
require "../helpers/rental.rb"
require "../helpers/car.rb"
require "../helpers/option.rb"
INSURANCE_FEE = 0.5
FEE = 0.3
ASSISTANCE_FEE = 100
def count_days rental
    start_date = Date.parse(rental["start_date"])
    end_date = Date.parse(rental["end_date"])
    (start_date..end_date).count
end

def load_data  from 
    file = File.read(from)
    data = JSON.parse(file)
    data["rentals"].map do |rent| 
        car = data["cars"].select {|car| car["id"].eql?(rent["car_id"])}.first
        opt = data["options"].select {|opt| opt["rental_id"].eql?(rent["id"])}
        Rental.new(rent, Car.new(car), opt)
    end

end