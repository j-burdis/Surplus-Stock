class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_item, only: [:show]
  before_action :store_user_location!, only: %i[index show]
  def index
    # if params[:query].present?
    #   @items = Item.search_by_name_and_description(params[:query])
    # else
    #   @items = Item.all
    # end
    @items = Item.all

    # Search functionality
    @items = @items.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?

    # Sorting functionality
    case params[:sort_by]
    when 'price_asc'
      @items = @items.order(price: :asc)
    when 'price_desc'
      @items = @items.order(price: :desc)
    when 'name_asc'
      @items = @items.order(name: :asc)
    when 'name_desc'
      @items = @items.order(name: :desc)
    end

    # If no results, show a message
    flash.now[:notice] = "No results found" if @items.empty?
  end

  def show
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end
end
