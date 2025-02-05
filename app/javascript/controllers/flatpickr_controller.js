import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  // Add static targets to ensure Stimulus recognizes the input
  static targets = ['input']

  connect() {
    console.log("Flatpickr controller connected");

    // Verify the input element exists and is correct
    if (!this.element) {
      console.error("No input element found for Flatpickr");
      return;
    }

    // Ensure the element is an input
    if (!(this.element instanceof HTMLInputElement)) {
      console.error("Flatpickr controller must be applied to an input element");
      return;
    }

    // Try initialization with explicit error handling
    try {
      this.initializeFlatpickr();
    } catch (error) {
      console.error("Flatpickr initialization failed:", error);
    }
  }

  initializeFlatpickr() {
    console.log("Attempting to initialize Flatpickr");

    // Get the current input value safely
    const currentValue = this.element.value || null;
    console.log("Current input value:", currentValue);

    
    const config = {
      altInput: true,
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      // defaultDate: defaultDate,
      minDate: "today", // new Date().fp_incr(1),
      disable: [
        function(date) {
          // Disable weekends
          return date.getDay() === 0 || date.getDay() === 6;
        }
      ]
      // enable: availableDates.length > 0 ? availableDates : undefined,
      // onChange: this.handleDateChange.bind(this)
    };

    // Carefully set default date
    if (currentValue) {
      try {
        const parsedDate = new Date(currentValue);
        if (!isNaN(parsedDate.getTime())) {
          config.defaultDate = parsedDate;
        }
      } catch (dateParseError) {
        console.warn("Could not parse current value as date:", dateParseError);
      }
    }

    // Add error handling wrapper around Flatpickr initialization
    try {
      this.flatpickr = flatpickr(this.element, {
        ...config,
        onReady: (selectedDates, dateStr, instance) => {
          console.log("Flatpickr is ready");
        },
        onError: (error) => {
          console.error("Flatpickr error:", error);
        }
      });

      console.log("Flatpickr initialized successfully");
    } catch (initError) {
      console.error("Critical Flatpickr initialization error:", initError);
      
      // Additional diagnostic information
      console.log("Element details:", {
        tagName: this.element.tagName,
        type: this.element.type,
        value: this.element.value,
        attributes: Array.from(this.element.attributes).map(attr => attr.name)
      });

      throw initError;
    }
  }
  
  async updateAvailableDates(event) {
    const orderId = event.detail?.orderId;
    if (!orderId) {
      console.warn("No order ID provided");
      return;
    } 
  
    console.log("Fetching available dates for order:", orderId);
    await this.fetchAvailableDates(orderId);
  } catch (error) {
    console.error("Error updating available dates:", error);
  }

  async fetchAvailableDates(orderId) {
    try {
      const response = await fetch(`/deliveries/available_dates?order_id=${orderId}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        }
      });

      if (!response.ok) {
        const data = await response.json();
        console.warn("Available dates fetch response not ok:", data);
        if (data.error === "Complete address required") {
          // return if address not complete yet
          return;
        }
        throw new Error('Network response was not ok');
      }

      const data = await response.json();
      console.log("Available dates received:", data.dates);

      // Convert date strings to Date objects
      const availableDates = data.dates.map(dateStr => {
        const date = new Date(dateStr);
        console.log("Parsed date:", date);
        return date;
      });
      
      // update flatpickr with new available dates
      if (this.flatpickr) {
        this.flatpickr.set('enable', availableDates);
        
        // clear if current date is not available
        const currentDate = this.flatpickr.selectedDates[0];
        if (currentDate && !data.dates.includes(currentDate.toISOString().split('T')[0])) {
          this.flatpickr.clear();
        }
      }
    } catch (error) {
      console.error('Error fetching available dates:', error);
    }
  }

  async handleDateChange(selectedDates, dateStr) {
    if (selectedDates.length > 0) {
      const form = this.element.closest('form');
      if (form) {
        const orderId = form.dataset.orderId;
        const messagesContainer = document.getElementById('delivery-date-messages');
        
        try {
          const response = await fetch(`/orders/${orderId}/save_delivery_date`, {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
            },
            body: JSON.stringify({ order: { delivery_date: dateStr } })
          });

          const data = await response.json();
          
          if (data.success) {
            this.showMessage(messagesContainer, 'success', 'Delivery date saved successfully');
          } else {
            this.showMessage(messagesContainer, 'error', data.errors.join(", "));
          }
        } catch (error) {
          console.error("Error:", error);
          this.showMessage(messagesContainer, 'error', 'An error occurred while saving the delivery date');
        }
      }
    }
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

  // disconnect() {
  //   if (this.flatpickr) {
  //     this.flatpickr.destroy()
  //   }
  // }
}
