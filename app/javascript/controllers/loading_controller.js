import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content"];

  connect() {
    const total = parseInt(this.data.get("total"));
    if (total > 0) {
      this.showContent();
    }else {
      this.showLoading();
    }
  }

  showLoading() {
    this.loadingTarget.style.display = "block";
    this.contentTarget.style.display = "none";
  }

  showContent() {
    this.loadingTarget.style.display = "none";
    this.contentTarget.style.display = "block";
  }
}
