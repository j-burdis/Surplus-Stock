import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quantityInput", "hiddenQuantity"];

  connect() {
    console.log("Basket controller connected");
    // Ensure hidden input is initially synced with visible input
    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity();
    }
  }

  validateQuantity(event) {
    const input = event.target;
    let value = parseInt(input.value) || 1
    value = Math.max(1, Math.min(value, parseInt(input.max)));
    input.value = value; // Ensure input value stays within bounds

    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity();
    }
  }

  updateHiddenQuantity() {
    // Get value from visible input
    const quantityValue = parseInt(this.quantityInputTarget.value) || 1
    console.log("Quantity input value:", quantityValue)

    this.hiddenQuantityTarget.value = quantityValue
    console.log("Hidden quantity set to:", this.hiddenQuantityTarget.value)
  }

  // This method will ensure that the hidden input is updated before the form is submitted
  submitForm(event) {
    console.log("Submitting form...");
    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity() // Make sure hidden quantity is updated before submission
    }
  }
}
