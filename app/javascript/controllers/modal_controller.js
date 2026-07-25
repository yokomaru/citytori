import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "form", "errors"];

  open() {
    this.modalTarget.showModal();
  }

  close() {
    this.formTarget.reset();
    this.errorsTarget.replaceChildren();
    this.modalTarget.close();
    this.dispatch("image-reset");
  }

  closeIfSubmitSuccess(event) {
    if (!event.detail.success) return;

    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.formTarget.reset();
    this.modalTarget.close();
    this.dispatch("image-reset");
  }
}
