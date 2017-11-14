class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :confirmation, :info, :google906057532e2dbb7e]

  def home
    @dev_redirection = "https://creermonecommerce.herokuapp.com/"
  end

  def confirmation
  end

  def info
    @dev_redirection = "https://creermonecommerce.herokuapp.com/#anchor-info"
  end

  def google906057532e2dbb7e
  end

  def robots
    render 'pages/robots.txt.erb'
    expires_in 6.hours, public: true
  end
end
