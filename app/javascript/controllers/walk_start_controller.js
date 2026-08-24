import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "status",
    "loadingIcon",
    "successIcon",
    "failedIcon",
    "startButton",
    "statusBox",
  ];

  open() {
    this.modalTarget.showModal();
    this.fetchPosition();
  }

  close() {
    this.modalTarget.close();
  }

  fetchPosition() {
    // 取得中の状態に戻す
    this.statusTarget.textContent = "位置情報を取得しています…";
    this.loadingIconTarget.classList.remove("hidden");
    this.successIconTarget.classList.add("hidden");
    this.failedIconTarget.classList.add("hidden");
    this.startButtonTarget.disabled = true;
    this.startButtonTarget.textContent = "散歩を始める";

    if (!navigator.geolocation) {
      this.statusTarget.textContent = "位置情報を取得できませんでした";
      this.loadingIconTarget.classList.add("hidden");
      this.successIconTarget.classList.add("hidden");
      this.failedIconTarget.classList.remove("hidden");
      this.startButtonTarget.disabled = false;
      this.startButtonTarget.textContent = "位置情報なしで散歩を始める";
      this.statusBoxTarget.classList.remove(
        "border-amber-300",
        "bg-amber-100",
        "text-amber-700",
      );

      this.statusBoxTarget.classList.add(
        "border-gray-300",
        "bg-gray-100",
        "text-gray-700",
      );
      return;
    }

    navigator.geolocation.getCurrentPosition(
      () => {
        this.statusTarget.textContent = "位置情報を取得できました";
        this.loadingIconTarget.classList.add("hidden");
        this.successIconTarget.classList.remove("hidden");
        this.failedIconTarget.classList.add("hidden");
        this.statusBoxTarget.classList.remove(
          "border-amber-300",
          "bg-amber-100",
          "text-amber-700",
        );

        this.statusBoxTarget.classList.add(
          "border-green-300",
          "bg-green-100",
          "text-green-700",
        );
        this.startButtonTarget.disabled = false;
      },
      () => {
        this.statusTarget.textContent = "位置情報を取得できませんでした";
        this.loadingIconTarget.classList.add("hidden");
        this.successIconTarget.classList.add("hidden");
        this.failedIconTarget.classList.remove("hidden");
        this.startButtonTarget.disabled = false;
        this.startButtonTarget.textContent = "位置情報なしで散歩を始める";
        this.statusBoxTarget.classList.remove(
          "border-amber-300",
          "bg-amber-100",
          "text-amber-700",
        );

        this.statusBoxTarget.classList.add(
          "border-gray-300",
          "bg-gray-100",
          "text-gray-700",
        );
      },
      {
        enableHighAccuracy: false,
        timeout: 10000,
        maximumAge: 0,
      },
    );
  }
}
