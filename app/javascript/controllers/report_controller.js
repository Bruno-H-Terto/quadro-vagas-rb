import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static targets = ["reportArea"];
  connect() {
    const result = this.data.get("status");
    if (result === "true") {
      this.reportAreaTarget.style.display = "block";
    } else {
      this.reportAreaTarget.style.display = "none";
    }
  }
}
