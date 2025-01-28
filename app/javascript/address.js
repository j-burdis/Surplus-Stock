document.addEventListener("turbo:load", function () {
  const saveAddressButton = document.getElementById("saveAddress");

  if (saveAddressButton) {
    saveAddressButton.addEventListener("click", function (e) {
      e.preventDefault();

      const addressForm = document.getElementById("addressForm");
      const orderId = addressForm.dataset.orderId; // Ensure the form has `data-order-id`

      // Get all the form fields
      const houseNumber = document.querySelector('[name="order[house_number]"]').value;
      const streetAddress = document.querySelector('[name="order[street_address]"]').value;
      const city = document.querySelector('[name="order[city]"]').value;
      const displayPostcode = document.querySelector('[name="order[display_postcode]"]').value;
      
      // Create the payload
      const payload = {
        order: {
          house_number: houseNumber,
          street_address: streetAddress,
          city: city,
          display_postcode: displayPostcode
        }
      };

      fetch(`/orders/${orderId}/save_address`, {
        method: "PATCH",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify(payload),
      })
      .then(response => {
        if (!response.ok) {
          return response.json().then(data => Promise.reject(data));
        }
        return response.json();
      })
      .then((data) => {
        const messageDiv = document.createElement("div");

        if (data.success) {
          // Show success message
          messageDiv.className = "bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4";
          messageDiv.textContent = data.message || "Address saved successfully";
        } else {
          messageDiv.className = "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4";
          messageDiv.textContent = data.errors ? data.errors.join(", ") : "Error saving address";
        }

         // Remove any existing messages
         const existingMessages = addressForm.querySelectorAll('.bg-green-100, .bg-red-100');
         existingMessages.forEach(msg => msg.remove());
         
         // Insert new message
         addressForm.insertBefore(messageDiv, addressForm.firstChild);
         
         // Remove message after 3 seconds
         setTimeout(() => messageDiv.remove(), 3000);
      })
      .catch(error => {
        console.error("Error:", error);
        const errorDiv = document.createElement("div");
        errorDiv.className = "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4";
        errorDiv.textContent = `Error: ${error.message}`;
        
        // Remove any existing messages
        const existingMessages = addressForm.querySelectorAll('.bg-green-100, .bg-red-100');
        existingMessages.forEach(msg => msg.remove());
        
        addressForm.insertBefore(errorDiv, addressForm.firstChild);
        setTimeout(() => errorDiv.remove(), 3000);
      });
    });
  }
});
