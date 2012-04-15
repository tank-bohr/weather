# coding: utf-8
module WeatherHelper

  class WeatherProvider
    @@site = 'http://pogoda.yandex.ru'

    def initialize(city_name = 'Москва')
      @agent = Mechanize.new
      @city = city_name.capitalize
      @page = find_city
    end


    # Проверяет страницу с погодой.
    # true - есть страница с погодой
    # false - страница с погодой не найдена
    def valid_city?
      elements = {}
      %w[desc tday tnight].each do |item_class|
        elements[item_class] = @page.at("td.b-forecast__item div.b-forecast__#{item_class}")
      end
      return !(elements['desc'].nil? && elements['tday'].nil? && elements['tnight'].nil?)
    end

    def day_temperature
      get_weather_info('tday')
    end

    def night_temperature
      get_weather_info('tnight')
    end

    def weather_description
      get_weather_info('desc')
    end

    private
    def find_city
      search_page = @agent.get(@@site + '/search/')
      search_form = search_page.form_with(:class => 'b-search')

      page = nil
      if search_form.kind_of?(Mechanize::Form)
        search_form.request = @city
        page = search_form.submit
      else
        Rails.logger.error("Cannot find search form on #{@@site}/search/")
      end

      return page

      #@agent.get(@@site + '/search/', ['request', @city])
    end


    def get_weather_info(class_name = 'desc')
      return nil if @page.nil?

      xpath_for_today = {
        'tday' => 'td div.b-thermometer__now',
        'tnight' => 'td div.b-thermometer div.b-thermometer__small-temp',
        'desc' => 'td div.b-info-item'
      }[class_name]

      today_info = nil
      if !xpath_for_today.nil?
        elem = @page.at(xpath_for_today)
        today_info = elem.text unless elem.nil?
      end
      today_info.chomp!(' °C') unless today_info.nil?

      weather_info = [today_info]
      elem = @page.at("td.b-forecast__item div.b-forecast__#{class_name}")
      if elem.nil?
        Rails.logger.warn("There is no information about city #{@city}")
        return nil
      end

      # родитель - элемент-ряд tr (table row)
      # его(ряд) и будем итерировать
      current = elem.parent
      (2..4).each do |i|
        if !current.children.nil? && ('b-forecast__gap__i' != current.children.attr('class').value)
          weather_info.push(current.children.text)
        end
        current = current.next
      end

      # Первые три элемента: сегодня, завтра, послезаавтра
      return weather_info.first(3)
    end

  end

end
