import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static values = { positions: Array, selectedId: String };
  static targets = ["placeholder", "selection"];

  connect() {
    if (this.positionsValue.length === 0) return;
    this.map = L.map(this.placeholderTarget);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);

    const bounds = L.latLngBounds(
      this.positionsValue.map((pos) => [pos.latitude, pos.longitude]),
    );
    for (const pos of this.positionsValue) {
      const link = document.createElement("a");
      link.href = pos.url;
      link.className = "walk-map-marker";
      link.dataset.turboFrame = "selected_walk_step";
      link.dataset.action = "click->walk-map#select";
      link.dataset.stepId = String(pos.id);
      link.setAttribute("aria-label", `${pos.number}. ${pos.word}の記録を見る`);
      const image = document.createElement("img");
      image.src = pos.image;
      image.alt = "";
      const number = document.createElement("span");
      number.textContent = String(pos.number);
      number.setAttribute("aria-hidden", "true");
      link.append(image, number);
      L.marker([pos.latitude, pos.longitude], {
        keyboard: false,
        icon: L.divIcon({
          className: "",
          html: link.outerHTML,
          iconSize: [56, 56],
          iconAnchor: [28, 28],
        }),
      }).addTo(this.map);
    }
    this.map.fitBounds(bounds, { maxZoom: 18 });
    this.highlightSelection(this.selectedIdValue);
  }

  select(event) {
    this.selectedIdValue = event.currentTarget.dataset.stepId;
    this.highlightSelection(this.selectedIdValue);
  }

  highlightSelection(selectedId) {
    for (const link of this.element.querySelectorAll("a[data-step-id]")) {
      if (link.dataset.stepId === selectedId) {
        link.setAttribute("aria-current", "true");
      } else {
        link.removeAttribute("aria-current");
      }
    }
  }

  revealSelection() {
    this.selectionTarget.focus({ preventScroll: true });
    this.selectionTarget.scrollIntoView({ block: "nearest" });
  }

  disconnect() {
    this.map?.remove();
  }
}
