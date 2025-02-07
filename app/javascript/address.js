// app/javascript/address.js
function initializeAddressForm() {
  const addressForm = document.getElementById("addressForm");
  if (!addressForm) return;

  // Ensure postcode input maintains full width
  const postcodeInput = document.querySelector('[data-address-lookup-target="postcodeInput"]');
  if (postcodeInput) {
    postcodeInput.classList.add('w-full');
  }

  // Show manual address section if any fields are filled
  const manualAddressDiv = addressForm.querySelector('[data-address-lookup-target="manualAddress"]');
  const addressFields = ['house_number', 'street_address', 'city', 'display_postcode'];
  
  const hasFilledFields = addressFields.some(field => {
    const input = document.querySelector(`[name="order[${field}]"]`);
    return input && input.value.trim() !== '';
  });

  if (hasFilledFields && manualAddressDiv) {
    manualAddressDiv.classList.remove('hidden');
  }

  // Initialize save address button functionality
  initializeSaveAddress(addressForm);
}

function initializeSaveAddress(addressForm) {
  const saveAddressButton = document.getElementById("saveAddress");
  if (!saveAddressButton) return;

  saveAddressButton.addEventListener("click", function(e) {
    e.preventDefault();

    if (!validateAddress()) {
      showMessage("Please fill in all address fields", true);
      return;
    }

    const orderId = addressForm.dataset.orderId;
    
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
      credentials: 'same-origin'
    })
    .then(response => {
      return response.json().then(data => {
        if (!response.ok) {
          return Promise.reject(data);
        }
        return data;
      });
    })
    .then((data) => {
      showMessage(data.message || "Address saved successfully");

      // trigger calendar update
      document.dispatchEvent(new CustomEvent('address:saved'));
    })
    .catch(error => {
      console.error("Error:", error);
      showMessage(error.errors ? error.errors.join(", ") : "Error saving address", true); 
    });
  });
}

function validateAddress() {
  const houseNumber = document.querySelector('[name="order[house_number]"]').value;
  const streetAddress = document.querySelector('[name="order[street_address]"]').value;
  const city = document.querySelector('[name="order[city]"]').value;
  const displayPostcode = document.querySelector('[name="order[display_postcode]"]').value;

  return houseNumber && streetAddress && city && displayPostcode;
}

function showMessage(message, isError = false) {
  const messageDiv = document.createElement("div");
  messageDiv.className = isError ? 
    "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" :
    "bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4";
  messageDiv.textContent = message;

  const addressForm = document.getElementById("addressForm");
  if (!addressForm) return;

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

document.addEventListener("turbo:render", initializeAddressForm);
document.addEventListener("turbo:load", initializeAddressForm);
