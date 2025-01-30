import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    this.flatpickr = flatpickr(this.element, {
      altInput: true,
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      minDate: "today",
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
                console.log("Delivery date saved successfully");
              } else {
                console.error("Error saving delivery date:", data.errors);
              }
            })
            .catch(error => console.error("Error:", error));
          }
        }
      }
    })
  }

  disconnect() {
    if (this.flatpickr) {
      this.flatpickr.destroy()
    }
  }
}
