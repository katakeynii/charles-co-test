class Option
    attr_reader :id, :rental_id, :type
    def initialize id, rental, type
        @id = id
        @rental = rental
        @type = type
    end
end