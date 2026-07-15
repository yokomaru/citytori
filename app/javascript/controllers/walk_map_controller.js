import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Connects to data-controller="walk-map"
export default class extends Controller {
  static values = {
    positions: Array,
  };

  static targets = ["placeholder"];

  connect() {
    if (this.positionsValue.length === 0) return;

    this.map = L.map(this.placeholderTarget).setView(
      [this.positionsValue[0][0], this.positionsValue[0][1]],
      18,
    );

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);

    for (const pos of this.positionsValue) {
      L.marker([pos[0], pos[1]]).addTo(this.map);
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
