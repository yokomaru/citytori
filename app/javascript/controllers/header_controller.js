import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "button"];

  toggle() {
    const expanded = this.buttonTarget.getAttribute("aria-expanded") === "true";
    this.menuTarget.classList.toggle("hidden", expanded);
    this.buttonTarget.setAttribute("aria-expanded", String(!expanded));
  }

  close(event) {
    if (event.type === "click" && this.element.contains(event.target)) return;
    if (this.buttonTarget.getAttribute("aria-expanded") !== "true") return;
    this.menuTarget.classList.add("hidden");
    this.buttonTarget.setAttribute("aria-expanded", "false");
    if (event.type === "keydown") {
      event.preventDefault();
      this.buttonTarget.focus();
    }
  }
}
