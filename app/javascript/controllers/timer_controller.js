// app/javascript/controllers/timer_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["timer"];

  connect() {
    // Clear any existing intervals when connecting
    this.startCountdown();
    console.log("timer connected")
  }

  disconnect() {
    this.stopAllTimers()
  }

  stopAllTimers() {
    this.timerTargets.forEach(timer => {
      if (timer.interval) {
        clearInterval(timer.interval)
        timer.interval = null
      }
    })
  }

  startCountdown() {
    this.stopAllTimers()
    
    this.timerTargets.forEach(timer => {
      const expirationTime = parseInt(timer.dataset.expirationTime, 10)
      if (!isNaN(expirationTime)) {
        this.startTimerCountdown(timer, expirationTime)
      }
    })
  }

  startTimerCountdown(timer, remainingSeconds) {
    // Initial display
    this.updateTimerDisplay(timer, remainingSeconds)

    // Set up the interval
    timer.interval = setInterval(() => {
      remainingSeconds -= 1
      
      if (remainingSeconds <= 0) {
        clearInterval(timer.interval)
        this.handleExpiration(timer)
      } else {
        this.updateTimerDisplay(timer, remainingSeconds)
      }
    }, 1000)
  }

  updateTimerDisplay(timer, timeLeft) {
    // if (timeLeft <= 0) {
    //   timer.textContent = "Expired";
    //   return;
    // }

    const minutes = Math.floor(timeLeft / 60);
    const seconds = timeLeft % 60;
    timer.textContent = `${minutes}:${seconds.toString().padStart(2, "0")}`;

    // setTimeout(() => this.updateTimer(timer, timeLeft - 1), 1000);
  }

  handleExpiration(timer) {
    timer.textContent = "Expired";
    this.disableResumePaymentButton();
  }

  // Disable the 'Resume Payment' button when time expires
  disableResumePaymentButton() {
    const disableButton = document.querySelector('[data-disable="true"]');
    if (disableButton) {
      disableButton.classList.add("disabled");
      disableButton.setAttribute("disabled", "true");
    }
  }
}
