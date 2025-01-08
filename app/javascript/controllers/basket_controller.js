import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quantityInput", "hiddenQuantity"];

  connect() {
    console.log("Basket controller connected");
    // Ensure hidden input is initially synced with visible input
    this.updateHiddenQuantity();
  }

  validateQuantity(event) {
    const input = event.target;
    const value = Math.max(1, Math.min(parseInt(input.value), parseInt(input.max)));
    input.value = value; // Ensure input value stays within bounds
  }  

  updateHiddenQuantity() {
    // Get value from visible input
    const quantityValue = this.quantityInputTarget.value;

    // Update hidden input with same value
    this.hiddenQuantityTarget.value = quantityValue;
  }
}
