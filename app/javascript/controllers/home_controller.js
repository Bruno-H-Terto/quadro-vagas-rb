import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  static targets = ["content"]
  connect() {
    setInterval(() => {
      this.contentTarget.textContent = 'Hello World com Stimulus'
    }, 3000);
  }
}
