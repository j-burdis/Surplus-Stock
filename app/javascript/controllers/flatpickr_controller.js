import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    const postcode = document.querySelector('[data-address-lookup-target="displayPostcodeInput"]').value

    fetch(`/deliveries/available_dates?postcode=${encodeURIComponent(postcode)}`)
      .then(response => response.json())
      .then(data => {
        this.initializeFlatpickr(data.dates);
      });
  }

  initializeFlatpickr(availableDates) {

    const defaultDate = this.element.value || null;
  
    this.flatpickr = flatpickr(this.element, {
      altInput: true,
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      defaultDate: defaultDate,
      minDate: "today",
      enable: availableDates,
      disable: [
        function(date) {
          // Disable weekends
          return date.getDay() === 0 || date.getDay() === 6;
        }
      ],
      onChange: (selectedDates, dateStr) => {
        if (selectedDates.length > 0) {
          const form = this.element.closest('form');
          if (form) {
            const orderId = form.dataset.orderId;
            const messagesContainer = document.getElementById('delivery-date-messages');
            
            fetch(`/orders/${orderId}/save_delivery_date`, {
              method: "PATCH",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
              },
              body: JSON.stringify({ order: { delivery_date: dateStr } })
            })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                // console.log("Delivery date saved successfully");
                this.showMessage(messagesContainer, 'success', 'Delivery date saved successfully');
              } else {
                // console.error("Error saving delivery date:", data.errors);
                this.showMessage(messagesContainer, 'error', data.errors.join(", "))
              }
            })
            .catch(error => {
              console.error("Error:", error);
              this.showMessage(messagesContainer, 'error', 'An error occurred while saving the delivery date');
            });
          }
        }
      }
    })
  }

  showMessage(container, type, message) {
    const alertClass = type === 'success' ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700';
    
    const alertHtml = `
      <div class="border ${alertClass} px-4 py-3 rounded relative mb-4" role="alert">
        <span class="block sm:inline">${message}</span>
      </div>
    `;
    
    container.innerHTML = alertHtml;
    
    // Clear message after 3 seconds
    setTimeout(() => {
      container.innerHTML = '';
    }, 3000);
  }

  disconnect() {
    if (this.flatpickr) {
      this.flatpickr.destroy()
    }
  }
}
