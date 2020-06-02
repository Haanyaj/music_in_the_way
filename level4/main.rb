require 'json'
require'date'


class Rentals
    attr_accessor :id , :car_id, :start_date, :end_date, :distance

    def initialize(id, car_id, start_date, end_date, distance)
        @id = id
        @car_id = car_id
        @start_date = start_date
        @end_date = end_date
        @distance = distance
    end
end

class Cars
    attr_accessor :id, :price_per_day, :price_per_km
  
    def initialize(id, price_per_day, price_per_km)
        @id = id
        @price_per_day = price_per_day
        @price_per_km = price_per_km
    end
end

def calculate_date(start_date, end_date)
    result = (Date.parse(start_date)...Date.parse(end_date)).count + 1
    return result
end

def calculate_price_km(price_km, distance)
    result = price_km * distance
    return result
end

def calculate_price_day(day, price)
    days_left = day
    result = 0
    while (days_left > 0)
        if (days_left == 1)
            result = result + price
            days_left = days_left - 1
        end
        if (days_left > 1 && days_left <= 4)
            new_price = price
            new_price = (price - (new_price * 10 / 100))
            result = result + new_price
            days_left = days_left - 1
        end
        if (days_left > 4 && days_left <= 10)
            new_price = price
            new_price = (price - (new_price * 30 / 100))
            result = result + new_price
            days_left = days_left - 1
        end
        if (days_left > 10)
            new_price = price
            new_price = (price - (new_price * 50 / 100))
            result = result + new_price
            days_left = days_left - 1
        end
    end
    return result
end


def file_parsing()
    file = File.read('data/input.json')
    data = JSON.parse(file)
    return data
end

def total_price(a, b)
    val = a + b
    return (val)
end

def commission(price, days)
    com = price * 30 / 100
    insurance = com / 2
    assistance = days * 100
    drivy = com - insurance - assistance
    owner_real_amount = price - com
    json = {
        "who" => "driver",
        "type" => "debit",
        "amount" => price,
    },
    {
        "who" => "owner",
        "type" => "credit",
        "amount" => owner_real_amount
    },
    {
        "who" => "insurance",
        "type" => "credit",
        "amount" => insurance
    },
    {
        "who" => "assistance",
        "type" => "credit",
        "amount" => assistance
    },
    {
        "who" => "drivy",
        "type" => "credit",
        "amount" => drivy
    }

    return json
end

def do_all(cars, rentals)
    json = {"rentals" => []}
    for i in (0...rentals.length)
        for j in (0...cars.length)
            if (cars[j].id == rentals[i].car_id)
                price_km = calculate_price_km(cars[j].price_per_km,rentals[i].distance)
                price_day = calculate_price_day(calculate_date(rentals[i].start_date,rentals[i].end_date), cars[j].price_per_day)
                price = total_price(price_day,price_km)
                com = commission(price, calculate_date(rentals[i].start_date,rentals[i].end_date))
                hash = {
                    "id" => rentals[i].id,
                    "actions" => com
                }
                json["rentals"].push(hash)
            end
        end
    end
    return json
end

#parsing json input
data = file_parsing()

#do all object needed 
cars = data['cars'].inject([]) { |o,d,| o << Cars.new( d['id'], d['price_per_day'], d['price_per_km']) }
rentals = data['rentals'].inject([]) { |o,d,| o << Rentals.new( d['id'],d['car_id'], d['start_date'], d['end_date'],d['distance']) }

#get final json 
res = do_all(cars, rentals)

File.open("data/output.json", "w") do |f|  
    f.write(JSON.pretty_generate(res))
end