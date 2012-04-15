module FavoritesHelper

  def add_favorite(city, url)
    client_id = cookies[:client_id]
    if client_id.nil?
      client_id = new_client_id()
      cookies[:client_id] = client_id
    end

    if Favorite.where(:client_id => client_id, :url => url).first.nil?
      Favorite.create(:client_id => client_id, :city => city, :url => url)
    end

  end



  def new_client_id
    Digest::MD5.hexdigest(request.remote_ip.to_s + Time.now.to_i.to_s + rand.to_s)
  end
end
