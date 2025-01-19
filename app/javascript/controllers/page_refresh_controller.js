import { Controller } from "@hotwired/stimulus"
import { visit } from "@hotwired/turbo"

export default class extends Controller {
  connect() {
    this.handleVisit = this.handleVisit.bind(this)
    document.addEventListener('turbo:visit', this.handleVisit)
  }

  disconnect() {
    document.removeEventListener('turbo:visit', this.handleVisit)
  }

  handleVisit(event) {
    const currentPath = window.location.pathname
    if (currentPath === '/basket') {
      event.detail.visit.action = "replace"
    }
  }

  // Call this method when navigating back to basket
  refreshPage() {
    if (window.location.pathname === '/basket') {
      visit(window.location.href, { action: "replace" })
    }
  }
}