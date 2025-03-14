class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_item, only: [:show]
  before_action :store_user_location!, only: %i[index show]
  def index
    # Search functionality
    if params[:query].present?
      @items = Item.search_by_name_and_description(params[:query])

      # apply the order differently for search results
      case params[:sort_by]
      when 'price_asc'
        @items = @items.reorder(price: :asc)
      when 'price_desc'
        @items = @items.reorder(price: :desc)
      when 'name_asc'
        @items = @items.reorder(name: :asc)
      when 'name_desc'
        @items = @items.reorder(name: :desc)
      end
    else
      # get all items with sorting when no search query
      @items = Item.all

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
    end

    # show a message if no results
    flash.now[:notice] = "No results found" if @items.empty?
  end

  def show
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end
end
