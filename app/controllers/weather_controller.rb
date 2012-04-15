# coding: utf-8
class WeatherController < ApplicationController
  def index
    @answer = nil
  end

  def query_weather
    wp = WeatherHelper::WeatherProvider.new(params[:city])
    if (wp.valid_city?)
      @answer = {}
      [:weather_description, :day_temperature, :night_temperature].each do |item|
        @answer[item] = wp.send(item)
      end

      render :index
    else
      @answer = nil
      render :index, :alert => 'Данных о погоде для данного города не найдено'
    end

  end
end
