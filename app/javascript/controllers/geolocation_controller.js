import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="geolocation"
export default class extends Controller {
  static targets = ["latitude", "longitude", "status", "position"];

  connect() {
    if (this.latitudeTarget.value && this.longitudeTarget.value) {
      this.showPosition(this.latitudeTarget.value, this.longitudeTarget.value);
      this.showStatus("位置情報を取得済みです。");
    }
  }

  fetchPosition() {
    if (!navigator.geolocation) {
      this.showStatus("このブラウザでは位置情報を取得できません。");
      return;
    }

    this.showStatus("位置情報を取得しています...");

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const latitude = position.coords.latitude;
        const longitude = position.coords.longitude;

        this.latitudeTarget.value = latitude;
        this.longitudeTarget.value = longitude;

        this.showStatus("位置情報を取得しました。");
        this.showPosition(latitude, longitude);
      },
      () => {
        this.latitudeTarget.value = "";
        this.longitudeTarget.value = "";

        this.showStatus(
          "位置情報を取得できませんでした。位置情報なしで登録できます。",
        );
        this.clearPosition();
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0,
      },
    );
  }

  showStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }

  showPosition(latitude, longitude) {
    if (this.hasPositionTarget) {
      this.positionTarget.textContent = `緯度: ${latitude}, 経度: ${longitude}`;
    }
  }

  clearPosition() {
    if (this.hasPositionTarget) {
      this.positionTarget.textContent = "";
    }
  }

  removeGeolocationInfo() {
    this.latitudeTarget.value = "";
    this.longitudeTarget.value = "";
    this.statusTarget.textContent = "";
    this.positionTarget.textContent = "";
  }
}
