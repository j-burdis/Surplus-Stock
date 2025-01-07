class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_item, only: [:show]
  def index
    @items = Item.all
  end

  def show
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end
end
