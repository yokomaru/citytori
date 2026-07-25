import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "form", "errors"];

  open() {
    this.modalTarget.showModal();
  }

  close() {
    this.modalTarget.close();
    this.formTarget.reset();

    console.log("削除前:", this.errorsTarget.innerHTML);

    this.errorsTarget.replaceChildren();

    console.log("削除後:", this.errorsTarget.innerHTML);
    this.dispatch("image-reset");
  }

  closeIfSubmitSuccess(event) {
    if (!event.detail.success) return;

    this.modalTarget.close();
    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.formTarget.reset();
    this.dispatch("image-reset");
  }
}
