import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static targets = ["btn"];
  connect() {
    const result = this.data.get("status");
    if (result === "true") {
      this.btnTarget.style.display = "block";
    } else {
      this.btnTarget.style.display = "none";
    }
  }
}
