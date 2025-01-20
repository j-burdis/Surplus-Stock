import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quantityInput", "hiddenQuantity"];

  connect() {
    // console.log("Basket controller connected");
    // Ensure hidden input is initially synced with visible input
    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity();
    }
  }

  validateQuantity(event) {
    const input = event.target;

    // Allow the field to be temporarily empty
    if (input.value === "") {
      return; // Do not auto-correct during typing
    }

    let value = parseInt(input.value, 10)
    const max = parseInt(input.max, 10);

    if (value > max) {
      value = max;
    } else if (value < 1) {
      value = ""; // Allow temporary invalid state
    }

    // value = Math.max(1, Math.min(value, parseInt(input.max)));
    input.value = value; // Ensure input value stays within bounds

    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity();
    }
  }

  // checkQuantityBeforeSubmit(event) {
  //   const input = this.quantityInputTarget;

  //   // Ensure the field has a valid value before losing focus
  //   if (input.value === "" || parseInt(input.value, 10) < 1) {
  //     input.value = 1; // Default to 1 if empty or less than 1
  //   }

  //   if (this.hasHiddenQuantityTarget) {
  //     this.updateHiddenQuantity();
  //   }
  // }

  updateHiddenQuantity() {
    // Get value from visible input
    const quantityValue = parseInt(this.quantityInputTarget.value) || 1
    // console.log("Quantity input value:", quantityValue)

    this.hiddenQuantityTarget.value = quantityValue
    // console.log("Hidden quantity set to:", this.hiddenQuantityTarget.value)
  }

  // This method will ensure that the hidden input is updated before the form is submitted
  submitForm(event) {
    // console.log("Submitting form...");
    event.preventDefault()

    const form = event.target
    const input = this.quantityInputTarget ? this.quantityInputTarget : form.querySelector('input[name="quantity"]')
    const value = parseInt(input.value, 10);
    const max = parseInt(input.max, 10);

    // Prevent submission if value is invalid
    if (isNaN(value) || value < 1 || value > max) {
      // event.preventDefault();
      // alert(`Quantity must be between 1 and ${max}`);
      this.showNotification(`Quantity must be between 1 and ${max}`, false)
      return
    }

    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity() // Make sure hidden quantity is updated before submission
    }

    // Submit form via AJAX
    const formData = new FormData(form)

    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      this.showNotification(data.message, data.success)
      
      if (data.success) {
        // If we're updating quantity from the basket page, update the display
        if (form.method.toLowerCase() === 'patch') {
          // Optionally refresh the page or update totals via JavaScript
          window.location.reload()
        }
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showNotification('An error occurred. Please try again.', false)
    })
  }

  showNotification(message, isSuccess) {
    const notification = document.createElement('div')
    notification.className = `fixed bottom-4 right-4 px-6 py-3 rounded shadow-lg transition-opacity duration-500 ${
      isSuccess ? 'bg-green-500' : 'bg-red-500'
    } text-white`
    notification.textContent = message
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.style.opacity = '0'
      setTimeout(() => notification.remove(), 500)
    }, 3000)
  }
}
