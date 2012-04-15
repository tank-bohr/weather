# coding: utf-8
class WeatherController < ApplicationController
  include FavoritesHelper

  def index
    @answer = nil
  end

  def query_weather
    wp = WeatherHelper::WeatherProvider.new(params[:city])
    if wp.valid_city?
      @answer = wp.answer

      if params[:add_favorite]
        add_favorite(wp.city, wp.url)
      end

      render :index
    else
      @answer = nil
      render :index, :alert => 'Данных о погоде для данного города не найдено'
    end

  end


  def favorites
    @favorites = []
    client_id = cookies[:client_id]
    if !client_id.nil?
      data = Favorite.where(:client_id => client_id)
      data.each do |favorite|
        wp = WeatherHelper::WeatherProvider.new(favorite)
        @favorites.push(wp.answer)
      end
    end
  end

end
