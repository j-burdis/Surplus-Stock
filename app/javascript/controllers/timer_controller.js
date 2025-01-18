// app/javascript/controllers/timer_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["timer"];

  connect() {
    this.startCountdown();
    console.log("timer connected")
  }

  startCountdown() {
    this.timerTargets.forEach((timer) => {
      const expirationTime = parseInt(timer.dataset.expirationTime, 10); // Time in seconds
      console.log("Expiration Time: ", expirationTime); 
      if (!isNaN(expirationTime)) {
        this.updateTimer(timer, expirationTime);
      }
    });
  }

  updateTimer(timer, timeLeft) {
    if (timeLeft <= 0) {
      timer.textContent = "Expired";
      return;
    }

    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    timer.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`;

    setTimeout(() => this.updateTimer(timer, timeLeft - 1), 1000);
  }

  // Disable the 'Resume Payment' button when time expires
  disableResumePaymentButton(timer) {
    const disableButton = document.querySelector('[data-disable="true"]');
    if (disableButton) {
      disableButton.classList.add("disabled");
      disableButton.setAttribute("disabled", "true");
    }
  }
}
