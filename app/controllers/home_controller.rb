class HomeController < ApplicationController
  def index
    @items = Item.published.order("created_at DESC").page params[:page]
  end

  def new_captcha
  end

end