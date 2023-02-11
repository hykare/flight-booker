class FlightsController < ApplicationController
  def index
    @departure_airport_options = Airport.with_scheduled_departures.alphabetical.map do |a|
      ["#{a.name} (#{a.code})", a.id]
    end
    @arrival_airport_options = Airport.with_scheduled_arrivals.alphabetical.map { |a| ["#{a.name} (#{a.code})", a.id] }
    @dates = Flight.pluck(:start).map { |date| date.strftime('%d %b %Y') }.uniq

    set_form_values
    find_flights
  end

  private

  def find_flights
    @flights = if query_submitted?
                 Flight.search(flight_search_params)
               else
                 []
               end
  end

  def set_form_values
    if query_submitted?
      @selected_departure_airport = params[:departure_airport_id]
      @selected_arrival_airport = params[:arrival_airport_id]
    else
      @selected_departure_airport = nearest_airport || default_airport
    end
  end

  def nearest_airport
    Airport.near(user_location).first
  end

  def default_airport
    # Warsaw
    '761'
  end

  def user_location
    # empty array if location invalid (eg localhost) on the first request
    # empty string on subsequent requests
    # what happens if blocked by browser?
    cookies.fetch(:location, request.location.coordinates)
  end

  def query_submitted?
    params[:commit] ? true : false
  end

  def flight_search_params
    { departure_airport: params[:departure_airport_id],
      arrival_airport: params[:arrival_airport_id],
      no_of_passengers: params[:no_of_passengers],
      date: Date.parse(params[:date]) }
  end
end
