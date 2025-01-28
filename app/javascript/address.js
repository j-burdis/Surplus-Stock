document.addEventListener("turbo:load", function () {
  const saveAddressButton = document.getElementById("saveAddress");
  const paymentForm = document.getElementById("paymentForm");
  const addressForm = document.getElementById("addressForm");

  // check if address fields are filled
  function validateAddress() {
    const houseNumber = document.querySelector('[name="order[house_number]"]').value;
    const streetAddress = document.querySelector('[name="order[street_address]"]').value;
    const city = document.querySelector('[name="order[city]"]').value;
    const displayPostcode = document.querySelector('[name="order[display_postcode]"]').value;

    return houseNumber && streetAddress && city && displayPostcode;
  }

  // Show message function
  function showMessage(message, isError = false) {
    const messageDiv = document.createElement("div");
    messageDiv.className = isError ? 
      "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" :
      "bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4";
    messageDiv.textContent = message;

    // Remove any existing messages
    const existingMessages = addressForm.querySelectorAll('.bg-green-100, .bg-red-100');
    existingMessages.forEach(msg => msg.remove());

    // Find the div containing the address form
    const addressDiv = addressForm.querySelector('[data-controller="address-lookup"]');
    if (addressDiv) {
      addressDiv.appendChild(messageDiv);
    } else {
      addressForm.appendChild(messageDiv);
    }

    // Remove message after 3 seconds
    setTimeout(() => messageDiv.remove(), 3000);
  }

  if (saveAddressButton) {
    saveAddressButton.addEventListener("click", function (e) {
      e.preventDefault();

      if (!validateAddress()) {
        showMessage("Please fill in all address fields", true);
        return;
      }

      const orderId = addressForm.dataset.orderId;
      // const addressForm = document.getElementById("addressForm");
      // const orderId = addressForm.dataset.orderId; // Ensure the form has `data-order-id`
      
      // Create the payload
      const payload = {
        order: {
          house_number: document.querySelector('[name="order[house_number]"]').value,
          street_address: document.querySelector('[name="order[street_address]"]').value,
          city: document.querySelector('[name="order[city]"]').value,
          display_postcode: document.querySelector('[name="order[display_postcode]"]').value
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
        showMessage(data.message || "Address saved successfully");
      })
      .catch(error => {
        console.error("Error:", error);
        showMessage(error.errors ? error.errors.join(", ") : "Error saving address", true);
      });
    });
  }

  // fill address with saved data if it exists
  if (addressForm) {
    const manualAddressDiv = addressForm.querySelector('[data-address-lookup-target="manualAddress"]');
    const houseNumber = document.querySelector('[name="order[house_number]"]').value;
    const streetAddress = document.querySelector('[name="order[street_address]"]').value;
    const city = document.querySelector('[name="order[city]"]').value;
    const displayPostcode = document.querySelector('[name="order[display_postcode]"]').value;

    if (houseNumber || streetAddress || city || displayPostcode) {
      manualAddressDiv.classList.remove('hidden');
    }
  }
});
