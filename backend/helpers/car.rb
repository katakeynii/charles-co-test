class Car
    attr_reader :id, :price_per_km, :price_per_day
    def initialize data
        @id = data["id"]
        @price_per_day = data["price_per_day"]
        @price_per_km = data["price_per_km"]
    end
end