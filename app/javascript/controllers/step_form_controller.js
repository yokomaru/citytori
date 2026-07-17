import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "errors"];

  open() {
    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.modalTarget.style.display = "flex";
  }

  close() {
    this.element.reset();
    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.modalTarget.style.display = "none";

    this.dispatch("reset");
  }

  closeAfterSubmit(event) {
    if (!event.detail.success) return;

    this.element.reset();
    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.modalTarget.style.display = "none";
    this.dispatch("reset");
  }

  closeWhenBackgroundClicked(event) {
    if (event.target !== this.modalTarget) return;

    this.element.reset();
    if (this.hasErrorsTarget) this.errorsTarget.innerHTML = "";
    this.modalTarget.style.display = "none";
    this.dispatch("reset");
  }
}
