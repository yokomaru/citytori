import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.resume();
  }

  disconnect() {
    this.pause();
  }

  pause() {
    window.clearTimeout(this.timer);
  }

  resume() {
    this.pause();
    if (this.element.matches(":hover, :focus-within")) return;
    this.timer = window.setTimeout(() => this.dismiss(), 5000);
  }

  dismiss() {
    this.pause();
    this.element.remove();
  }
}
