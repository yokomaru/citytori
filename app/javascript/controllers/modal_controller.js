import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "form", "errors"];

  open() {
    this.returnFocus = this.element.querySelector(".active-walk-photo-button");
    this.modalTarget.showModal();
  }

  close() {
    this.formTarget.reset();
    this.errorsTarget.replaceChildren();
    this.modalTarget.close();
    this.dispatch("reset");
    this.returnFocus?.focus();
  }

  cancel(event) {
    event.preventDefault();
    this.close();
  }

  closeIfSubmitSuccess(event) {
    if (!event.detail.success) return;

    this.close();
  }
}
