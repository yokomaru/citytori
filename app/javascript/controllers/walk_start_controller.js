import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "loadingStatus",
    "successStatus",
    "failedStatus",
    "startButton",
  ];

  open() {
    this.modalTarget.showModal();
    this.fetchPosition();
  }

  close() {
    this.modalTarget.close();
  }

  fetchPosition() {
    this.showLoading();

    if (!navigator.geolocation) {
      this.showFailed();
      return;
    }

    navigator.geolocation.getCurrentPosition(
      () => {
        this.showSucceeded();
      },
      () => {
        this.showFailed();
      },
      {
        enableHighAccuracy: false,
        timeout: 10000,
        maximumAge: 0,
      },
    );
  }

  showLoading() {
    this.loadingStatusTarget.hidden = false;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = true;
    this.startButtonTarget.disabled = true;
    this.startButtonTarget.textContent = "散歩を始める";
  }

  showSucceeded() {
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = false;
    this.failedStatusTarget.hidden = true;
    this.startButtonTarget.disabled = false;
    this.startButtonTarget.textContent = "散歩を始める";
  }

  showFailed() {
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = false;
    this.startButtonTarget.disabled = false;
    this.startButtonTarget.textContent = "位置情報なしで散歩を始める";
  }
}
