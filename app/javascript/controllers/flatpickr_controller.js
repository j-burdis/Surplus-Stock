// app/javascript/controllers/flatpickr_controller.js
import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  // Add static targets to ensure Stimulus recognizes the input
  static targets = ['input']

  connect() {
    // Verify the input element exists and is correct
    if (!this.element) {
      console.error("No input element found for Flatpickr");
      return;
    }

    // Initialize Flatpickr with current settings
    this.initializeFlatpickr();

    // Listen for address changes
    document.addEventListener('address:saved', this.handleAddressUpdate.bind(this));
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener('address:saved', this.handleAddressUpdate.bind(this));
    if (this.flatpickr) {
      this.flatpickr.destroy();
    }
  }

  initializeFlatpickr() {
    // Get the current input value safely
    const currentValue = this.element.value || null;
    
    const config = {
      altInput: true,
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      // defaultDate: defaultDate,
      minDate: "today",
      clickOpens: false,
      disable: [true],
      // disable: [
      //   function(date) {
      //     // Disable Sunday
      //     return date.getDay() === 0;
      //   }
      // ],
      // enable: availableDates.length > 0 ? availableDates : undefined,
      onChange: this.handleDateChange.bind(this)
    };

    // Set default date if one exists
    if (currentValue) {
      const parsedDate = new Date(currentValue);
      if (!isNaN(parsedDate.getTime())) {
        config.defaultDate = parsedDate;
      }
    }

    this.flatpickr = flatpickr(this.element, config);

    // Get orderId from the form's data attribute
    const form = this.element.closest('form');
    if (form && form.dataset.orderId) {
      this.checkAddressAndFetchDates(form.dataset.orderId);
    } 
  }
  
  // Handler for when address is updated
  async handleAddressUpdate(event) {
    const orderId = this.element.closest('form')?.dataset.orderId;
    if (!orderId) return;

    // Clear the current date selection
    if (this.flatpickr) {
      this.flatpickr.clear();

      // calendar disabled while loading available dates
      this.flatpickr.set('disable', [true]);

      this.flatpickr.set('clickOpens', false);
      
      // Show loading state
      this.showMessage('Updating available delivery dates...', 'info');
      
      // Fetch new available dates
      await this.checkAddressAndFetchDates(orderId);
    }
  }

  async checkAddressAndFetchDates(orderId) {
    // First check if address is complete
    try {
      const response = await fetch(`/orders/${orderId}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        }
      });

      const data = await response.json();
      
      if (data.address_complete) {
        await this.fetchAvailableDates(orderId);
      } else {
        // Optionally disable the date picker until address is complete
        if (this.flatpickr) {
          this.flatpickr.set('disable', [true]); // Disable all dates
          this.showMessage('Complete your address to see available delivery dates', 'warning');
        }
      }
    } catch (error) {
      console.error('Error checking address status:', error);
      this.showMessage('Error checking address status', 'error');
    }
  }

  async fetchAvailableDates(orderId) {
    try {
      const response = await fetch(`/deliveries/available_dates?order_id=${orderId}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        }
      });

      const data = await response.json();
      // console.log('Available dates response:', data); 

      if (!response.ok) {
        console.log('Response not OK:', response.status, data); 
        if (data.error === "Complete address required") {
          if (this.flatpickr) {
            this.flatpickr.set('disable', [true]); // Disable all dates
          }
          // return if address not complete yet
          return;
        }
        throw new Error(data.error || 'Network response was not ok');
      }

      // Enable calendar and set available dates
      const availableDates = data.dates.map(dateStr => new Date(dateStr));

      // update flatpickr with new available dates
      if (this.flatpickr) {
        this.flatpickr.set('clickOpens', true);
        this.flatpickr.set('disable', [
          function(date) {
            // Keep Sundays disabled
            if (date.getDay() === 0) return true;
            
            // Check if date is in available dates
            return !availableDates.some(availableDate => 
              availableDate.toDateString() === date.toDateString()
            );
          }
        ]);
        
        // clear previously selected date that's no longer available
        const currentDate = this.flatpickr.selectedDates[0];
        if (currentDate && !data.dates.includes(currentDate.toISOString().split('T')[0])) {
          this.flatpickr.clear();
        }

        // clear loading message and show selection prompt
        this.showMessage('Choose a delivery date', 'warning', false);
      }
    } catch (error) {
      console.error('Error details:', error);
      this.showMessage('Unable to load available delivery dates', 'error');
      if (this.flatpickr) {
        this.flatpickr.set('disable', [true]);
      }
    }
  }

  async handleDateChange(selectedDates, dateStr) {
    if (selectedDates.length === 0) return;

    const form = this.element.closest('form');
    if (!form) return;

    const orderId = form.dataset.orderId;
    
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
        this.showMessage('Delivery date saved successfully', 'success');
      } else {
        this.showMessage(data.errors.join(", "), 'error');
        // Clear selection if save failed
        this.flatpickr.clear();
      }
    } catch (error) {
      console.error("Error:", error);
      this.showMessage('Error saving delivery date', 'error');
      this.flatpickr.clear();
    }
  }

  showMessage(message, type = 'info', autoHide = false ) {
    const container = document.getElementById('delivery-date-messages');
    if (!container) return;

    const classes = {
      error: 'bg-red-100 border-red-400 text-red-700',
      success: 'bg-green-100 border-green-400 text-green-700',
      warning: 'bg-yellow-100 border-yellow-400 text-yellow-700',
      info: 'bg-blue-100 border-blue-400 text-blue-700'
    };

    container.innerHTML = `
      <div class="border ${classes[type]} px-4 py-3 rounded relative mb-4" role="alert">
        <span class="block sm:inline">${message}</span>
      </div>
    `;
    
    // Clear success message after 3 seconds
    if (autoHide || type === 'success') {
      setTimeout(() => {
        container.innerHTML = '';
      }, 3000);
    }
  }
}
