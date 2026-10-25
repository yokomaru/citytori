import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="geolocation"
export default class extends Controller {
  static targets = [
    "latitude",
    "longitude",
    "loadingStatus",
    "successStatus",
    "failedStatus",
    "submit",
  ];

  connect() {
    if (this.latitudeTarget.value && this.longitudeTarget.value) {
      this.showSuccess();
    }
  }

  fetchPosition() {
    this.positionRequestId = (this.positionRequestId ?? 0) + 1;
    const requestId = this.positionRequestId;

    this.showLoading();

    if (!navigator.geolocation) {
      this.showFailed();
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        if (requestId !== this.positionRequestId) return;

        this.latitudeTarget.value = position.coords.latitude;
        this.longitudeTarget.value = position.coords.longitude;

        this.showSuccess();
      },
      () => {
        if (requestId !== this.positionRequestId) return;

        this.latitudeTarget.value = "";
        this.longitudeTarget.value = "";

        this.showFailed();
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0,
      },
    );
  }

  showLoading() {
    this.submitTarget.disabled = true;
    this.loadingStatusTarget.hidden = false;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = true;
  }

  showSuccess() {
    this.submitTarget.disabled = false;
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = false;
    this.failedStatusTarget.hidden = true;
  }

  showFailed() {
    this.submitTarget.disabled = false;
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = false;
  }

  removeGeolocationInfo() {
    this.positionRequestId = (this.positionRequestId ?? 0) + 1;

    this.latitudeTarget.value = "";
    this.longitudeTarget.value = "";

    this.showLoading();
  }
}
