import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="form"
export default class extends Controller {
  submit() {
    this.element.requestSubmit();
  }

  finishConfirm(event) {
    if (!window.confirm("しりとり散歩をおしまいにしますか？")) {
      event.stopImmediatePropagation();
    }
  }
}
