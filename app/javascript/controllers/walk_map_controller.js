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

    this.map = L.map(this.placeholderTarget);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);

    const bounds = L.latLngBounds(this.positionsValue);

    for (const pos of this.positionsValue) {
      L.marker([pos[0], pos[1]]).addTo(this.map);
    }

    this.map.fitBounds(bounds, { maxZoom: 18 });
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
