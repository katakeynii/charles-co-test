require "../helpers/range.rb"

class Rental
    attr_reader :id, :car_id, :start_date, :end_date, :distance, :car, :option
    def initialize data, car, options = nil
        @id = data["id"]
        @car_id = data["car_id"]
        @start_date = Date.parse data["start_date"]
        @end_date = Date.parse data["end_date"]
        @distance = data["distance"]
        @car = car
        @options = options
        @decrease_prices = [
            { range: 2..4, reduction: 0.1, method: :decrease_by_10},
            { range: 5..10, reduction: 0.3, method: :decrease_by_30},
            { range: 11..nil, reduction: 0.5, method: :decrease_by_50}
        ]
        @days = count_days
    end
    def to_static_price
        price = count_days * car.price_per_day + distance_price
        { 
            id: id,
            price: price,
        }
    end
    def to_decrease_price
        counted_day = @days
        decrease = @decrease_prices.select { |d| d[:range].include?(@days) }.first
        if decrease.nil?
            price = car.price_per_day
        else
            rented_day = @days.eql?(decrease[:range].min) ? 1 : @days - decrease[:range].min + 1
            price = send(decrease[:method], rented_day)
        end
        { 
            id: id,
            price: price + distance_price,
        }
    end
    
    def to_commission
        commission_amount = to_decrease_price[:price] * FEE 
        insurance = commission_amount * INSURANCE_FEE
        assistance_fee = @days * ASSISTANCE_FEE
        drivy_fee = commission_amount - (insurance + assistance_fee)
        to_decrease_price.update({ 
            commission: { 
                insurance_fee: insurance,
                assistance_fee: assistance_fee,
                drivy_fee: drivy_fee
            }
        })
    end

    def options_cost
        @options.inject({owner: 0, drivy: 0}) do |recipient, opt| 
            costs = {
                "gps": 5 * @days ,
                "baby_seat": 2 * @days,
                "additional_insurance": 10 * @days
            }
            recipient[:owner] += costs[opt["type"].to_sym] * 100 if ["gps","baby_seat"].include?(opt["type"])
            recipient[:drivy] += costs[opt["type"].to_sym] * 100 if "additional_insurance".eql?(opt["type"])
            recipient
        end
    end
    
    def to_balance_with_option
        opt_cost = options_cost
        opts = @options.map {|opt| opt["type"]}
        balance = to_balance
        balance[:options] = opts
        owner = balance[:actions].find {|act| act[:who].eql?("owner") }
        owner[:amount] += opt_cost[:owner]
        drivy = balance[:actions].find {|act| act[:who].eql?("drivy") }
        drivy[:amount] += opt_cost[:drivy] 
        driver = balance[:actions].find {|act| act[:who].eql?("driver") }
        driver[:amount] += (opt_cost[:drivy] + opt_cost[:owner])
        balance
    end

    def to_balance
        data = to_commission[:commission]
        price = to_commission[:price]
        owner_money = price - ( data[:insurance_fee] + data[:assistance_fee] + data[:drivy_fee] )
        {
            id: id,
            actions: [
                {
                    who: "driver",
                    type: "debit",
                    amount: price
                },
                {
                    who: "owner",
                    type: "credit",
                    amount: owner_money 
                },
                {
                    who: "insurance",
                    type: "credit",
                    amount: data[:insurance_fee]
                },
                {
                    who: "assistance",
                    type: "credit",
                    amount: data[:assistance_fee]
                },
                {
                    who: "drivy",
                    type: "credit",
                    amount: data[:drivy_fee]
                }
            ]
        }
    end

    def decrease_by_10 rented_day
        range = get_range_for_reduction 0.1
        decreased_price(0.1, rented_day) + car.price_per_day
    end

    def decrease_by_30 rented_day
        range = get_range_for_reduction 0.1
        decreased_price(0.3, rented_day) + decrease_by_10(range.max - range.min + 1)
    end

    def decrease_by_50 rented_day
        range = get_range_for_reduction 0.3
        decreased_price(0.5, rented_day) + decrease_by_30(range.max - range.min + 1)
    end
    
    def decreased_price reduction, n_days
        car.price_per_day * ( 1  - reduction) * n_days
    end

    def  get_range_for_reduction red
        range = @decrease_prices.select { |d| d[:reduction].eql?(red) }.first[:range]
    end
    
    def distance_price
        distance * car.price_per_km
    end
    
    def count_days
        (start_date..end_date).count
    end
    
end