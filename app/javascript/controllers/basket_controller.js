import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["hiddenQuantity"];

  connect() {
    console.log("Basket controller connected");
  }

  validateQuantity(event) {
    const input = event.target;
    const value = Math.max(1, Math.min(parseInt(input.value), parseInt(input.max)));
    input.value = value; // Ensure input value stays within bounds
  }  

  updateHiddenQuantity(event) {
    const input = event.target;
    if (this.hiddenQuantityTarget) {
      this.hiddenQuantityTarget.value = input.value; // Sync hidden field with visible input
    }
  }
}
