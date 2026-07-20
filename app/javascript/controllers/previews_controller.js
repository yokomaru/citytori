import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview", "image"];

  preview(e) {
    const file = e.target.files[0];
    const reader = new FileReader();

    reader.onload = (event) => {
      this.imageTarget.src = event.target.result;
      this.previewTarget.classList.remove("hidden");
    };
    reader.readAsDataURL(file);
  }
}
