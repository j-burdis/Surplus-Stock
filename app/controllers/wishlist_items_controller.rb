class WishlistItemsController < ApplicationController
  before_action :set_wishlist

  def create
    item = Item.find(params[:item_id])
    if @wishlist.wishlist_items.exists?(item: item)
      flash[:notice] = "Item is already in your wishlist."
    else
      @wishlist.wishlist_items.create(item: item)
      flash[:notice] = "#{item.name} has been added to your wishlist."
    end
    redirect_to item_path(item)
  end

  def destroy
    wishlist_item = @wishlist.wishlist_items.find(params[:id])
    wishlist_item.destroy
    flash[:notice] = "#{wishlist_item.item.name} removed from your wishlist."
    redirect_to wishlist_path
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end
end
