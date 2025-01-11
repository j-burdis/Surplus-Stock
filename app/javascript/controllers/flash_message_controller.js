// app/javascript/controllers/flash_message_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["message"];

  connect() {
    // Hide the message after 5 seconds
    setTimeout(() => {
      this.hideMessage();
    }, 5000);
  }

  // Method to hide the flash message
  hideMessage() {
    this.element.classList.add("hidden");
  }
}
