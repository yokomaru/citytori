import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview", "image"];

  disconnect() {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
    }
  }

  preview(e) {
    const file = e.target.files[0];

    if (!file) {
      this.inputTarget.value = "";
      this.imageTarget.src = "";
      this.previewTarget.classList.add("hidden");
      return;
    }

    const maxSizeOfBytes = 10 * 1024 * 1024; // 画像の最大サイズは10MB

    if (file.size > maxSizeOfBytes) {
      alert("画像のサイズは10MB以下にしてください");
      this.inputTarget.value = "";
      this.imageTarget.src = "";
      this.previewTarget.classList.add("hidden");
      return;
    }

    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
    }

    this.objectUrl = URL.createObjectURL(file);
    this.imageTarget.src = this.objectUrl;
    this.previewTarget.classList.remove("hidden");
  }
}
