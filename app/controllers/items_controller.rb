class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_item, only: [:show]
  def index
    if params[:query].present?
      @items = Item.search_by_name_and_description(params[:query])
    else
      @items = Item.all
    end
  end

  def show
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end
end
