import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["quantityInput", "hiddenQuantity", "stockDisplay"];

  connect() {
    // Ensure hidden input is initially synced with visible input
    if (this.hasHiddenQuantityTarget && this.hasQuantityInputTarget) {
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

    input.value = value; // Ensure input value stays within bounds

    if (this.hasHiddenQuantityTarget) {
      this.updateHiddenQuantity();
    }
  }

  updateHiddenQuantity() {
    // Get value from visible input
    const quantityValue = parseInt(this.quantityInputTarget.value) || 1
    this.hiddenQuantityTarget.value = quantityValue
  }

  // This method will ensure that the hidden input is updated before the form is submitted
  submitForm(event) {
    event.preventDefault()

    const form = event.target
    let quantity;

    // check if quick add or regular add
    if (this.hasQuantityInputTarget) {
      const input = this.quantityInputTarget;
      quantity = parseInt(input.value, 10);
      const max = parseInt(input.max, 10);

      if (isNaN(quantity) || quantity < 1 || quantity > max) {
        this.showNotification(`Quantity must be between 1 and ${max}`, false)
        return
      }
    } else {
      // Quick add - quantity is always 1
      quantity = 1;
    }

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
    .then(response => {
      if (response.ok) {
        return response.json();
      } else if (response.status === 401) {
        window.location.href = '/users/sign_in';
        return null;
      } else {
        throw new Error('Something went wrong');
      }
    })
    .then(data => {
      const flashContainer = document.querySelector('#flash-messages')
      if (flashContainer) {
        flashContainer.innerHTML = `
        <div class="flash-message flash-${data.flash.type} ${data.flash.type === 'notice' ? 'flash-notice' : 'flash-alert'}" data-controller="flash-message">
          <span class="flash-message-text">${data.flash.text}</span>
          <button class="flash-close-btn" data-action="click->flash-message#hideMessage">
            <i class="fas fa-times"></i>
          </button>
        </div>
      `
      }
    
      // this.showNotification(data.message, data.success)
      
      if (data.success) {
        // Check for the hidden _method field instead of form.method
        const methodInput = form.querySelector('input[name="_method"]');
        const httpMethod = methodInput ? methodInput.value.toLowerCase() : form.method.toLowerCase();
        
        if (httpMethod === 'patch') {
          this.updateOrderSummary()
        }

        this.updateStockDisplay(value)
      }
    })
    .catch(error => {
      this.showNotification('An error occurred. Please try again.', false)
    })
  }

  updateOrderSummary() {
  
    fetch('/basket', {
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: 'same-origin'
    })

    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const orderSummarySection = document.querySelector('.order-summary')
        if (orderSummarySection) {
          orderSummarySection.innerHTML = data.html
        }
      }
    })
    .catch(error => {
      console.error('Error updating order summary:', error)
    })
  }

  updateStockDisplay(quantity) {
    if (this.hasStockDisplayTarget) {
      const stockElement = this.stockDisplayTarget;
      const currentStock = parseInt(stockElement.textContent.replace(/\D/g, ''), 10);
      const newStock = currentStock - quantity;
      stockElement.textContent = `Stock remaining: ${newStock}`;
    }
  }
}

// showNotification(message, isSuccess) {
//   const notification = document.createElement('div')
//   notification.className = `fixed bottom-4 right-4 px-6 py-3 rounded shadow-lg transition-opacity duration-500 ${
//     isSuccess ? 'bg-lighterBlue' : 'bg-red-400'
//   } text-white`
//   notification.textContent = message
//   document.body.appendChild(notification)
  
//   setTimeout(() => {
//     notification.style.opacity = '0'
//     setTimeout(() => notification.remove(), 500)
//   }, 3000)
// }
