module APIHelpers
  def warden
    env['warden']
  end
  
  # items helpers
  def max_page_size
    100
  end

  def default_page_size
    15
  end

  def page_size
    size = params[:size].to_i
    [size.zero? ? default_page_size : size, max_page_size].min
  end

  # user helpers
  def current_user
    token = params[:token] || oauth_token
    @current_user ||= MimiUser.try_login(token) if token
  end
  
 

  def authenticate!
    error!({:status => "0", "msg" => "Unauthorized" }, 401) unless current_user
  end
  
 
  
 
 
  
end