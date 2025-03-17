import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chart"];

  connect() {
    this.createChart();
  }

  createChart() {
    const successCount = parseInt(this.data.get("success"));
    const failedCount = parseInt(this.data.get("failed"));
    const total = successCount + failedCount;

    const maxHeight = 300;
    const successHeight = (successCount / total) * maxHeight;
    const failedHeight = (failedCount / total) * maxHeight;

    const successBar = this.chartTarget.querySelector(".success");
    const failedBar = this.chartTarget.querySelector(".failed");

    successBar.style.height = `${successHeight}px`;
    failedBar.style.height = `${failedHeight}px`;
  }
}
