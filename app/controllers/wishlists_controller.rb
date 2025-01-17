class WishlistsController < ApplicationController
  def show
    @wishlist = current_user.wishlist
    @wishlist_items = @wishlist.wishlist_items.includes(:item)
  end
end
