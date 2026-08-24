import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="geolocation"
export default class extends Controller {
  static targets = [
    "latitude",
    "longitude",
    "loadingStatus",
    "successStatus",
    "failedStatus",
  ];

  connect() {
    if (this.latitudeTarget.value && this.longitudeTarget.value) {
      this.showSuccess();
    }
  }

  fetchPosition() {
    this.showLoading();

    if (!navigator.geolocation) {
      this.showFailed();
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latitudeTarget.value = position.coords.latitude;
        this.longitudeTarget.value = position.coords.longitude;

        this.showSuccess();
      },
      () => {
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
    this.loadingStatusTarget.hidden = false;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = true;
  }

  showSuccess() {
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = false;
    this.failedStatusTarget.hidden = true;
  }

  showFailed() {
    this.loadingStatusTarget.hidden = true;
    this.successStatusTarget.hidden = true;
    this.failedStatusTarget.hidden = false;
  }

  removeGeolocationInfo() {
    this.latitudeTarget.value = "";
    this.longitudeTarget.value = "";

    this.showLoading();
  }
}
