import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview", "image"];

  preview(e) {
    const file = e.target.files[0];

    if (!file) {
      this.inputTarget.value = "";
      this.imageTarget.src = "";
      this.previewTarget.style.display = "none";
      return;
    }

    const allowedMime = ["image/jpeg", "image/jpg", "image/png"];
    const maxBytes = 10 * 1024 * 1024; // 10MBに制限する

    if (!allowedMime.includes(file.type)) {
      alert("JPEG、JPG、PNG形式のファイルを選択してください。");
      this.inputTarget.value = "";
      this.imageTarget.src = "";
      this.previewTarget.style.display = "none";
      return;
    }

    if (file.size > maxBytes) {
      alert("画像は10MB以下にしてください。");
      this.inputTarget.value = "";
      this.imageTarget.src = "";
      this.previewTarget.style.display = "none";
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      this.imageTarget.src = event.target.result;
      this.previewTarget.style.display = "block";
    };
    reader.readAsDataURL(file);

    this.dispatch("valid-file-selected");
  }
}