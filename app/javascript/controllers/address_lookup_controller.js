import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "postcodeInput",
    "addressSelect",
    "addressSelection",
    "manualAddress",
    "houseNumberInput",
    "streetInput",
    "cityInput",
    "displayPostcodeInput",
    "loading"
  ]

  async searchPostcode() {
    const postcode = this.postcodeInputTarget.value.trim()
    if (!postcode) return

    try {
      // Show loading state
      this.loadingTarget.classList.remove('hidden')
      this.addressSelectionTarget.classList.add('hidden')
      this.manualAddressTarget.classList.add('hidden')

      const response = await fetch(`/api/address_lookup?postcode=${encodeURIComponent(postcode)}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (!response.ok) throw new Error('Network response was not ok')

      const addresses = await response.json()
      console.log('Received addresses:', addresses)

      if (addresses && addresses.length > 0 && addresses.some(addr => addr.formatted_address)) {
        this.addressSelectionTarget.classList.remove('hidden')
        this.addressSelectTarget.innerHTML = '<option value="">Select your address</option>'
        
        addresses.forEach(address => {
          // console.log('Processing address:', address)
          if (address.formatted_address) {
            const option = document.createElement('option')
            const addressData = {
              street_address: address.street_address || '',
              city: address.city || '',
              postcode: address.postcode || '',
              coordinates: address.coordinates || null // Store coordinates if needed later
            }
            // console.log('Address data for option:', addressData)
            option.value = JSON.stringify(addressData)
            option.textContent = address.formatted_address || 'Unknown address'
            this.addressSelectTarget.appendChild(option)
          }
        })
      } else {
        console.log('No addresses found')
        // Show manual input if no addresses found
        this.showManualInput()
      }
    } catch (error) {
      console.error('Error fetching addresses:', error)
      this.showManualInput()
    } finally {
      // Hide loading state
      this.loadingTarget.classList.add('hidden')
    }
  }

  updateAddress(event) {
    try {
      const selectedValue = this.addressSelectTarget.value
      if (!selectedValue) {
        this.manualAddressTarget.classList.add('hidden')
        return
      }

      const selectedAddress = JSON.parse(selectedValue)
      this.manualAddressTarget.classList.remove('hidden')
      this.streetInputTarget.value = selectedAddress.street_address || ''
      this.cityInputTarget.value = selectedAddress.city || ''
      this.displayPostcodeInputTarget.value = selectedAddress.postcode || this.postcodeInputTarget.value
      this.houseNumberInputTarget.value = ''
      
      // Add hidden input for coordinates if needed
      const coordsInput = document.getElementById('payment_coordinates')
      if (coordsInput && selectedAddress.coordinates) {
        coordsInput.value = JSON.stringify(selectedAddress.coordinates)
      }
    } catch (error) {
      console.error('Error updating address:', error)
      this.showManualInput()
    }
  }

  showManualInput() {
    this.manualAddressTarget.classList.remove('hidden')
    this.addressSelectionTarget.classList.add('hidden')
    // Clear any existing values
    this.houseNumberInputTarget.value = ''
    this.streetInputTarget.value = ''
    this.cityInputTarget.value = ''
    this.displayPostcodeInputTarget.value = this.postcodeInputTarget.value
  }
}
