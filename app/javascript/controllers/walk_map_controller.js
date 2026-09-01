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

    const bounds = L.latLngBounds(
      this.positionsValue.map((pos) => [pos.latitude, pos.longitude]),
    );

    for (const pos of this.positionsValue) {
      const icon = L.divIcon({
        className: "",
        html: `
          <a
            href="${pos.url}"
            data-turbo-frame="selected_walk_step"
            class="
              block h-14 w-14 overflow-hidden
              rounded-full border-4 border-white
              bg-white shadow-md
            "
          >
            <img
              src="${pos.image}"
              alt=""
              class="h-full w-full rounded-full object-cover"
            >
          </a>
        `,
        iconSize: [56, 56],
        iconAnchor: [28, 28],
      });

      L.marker([pos.latitude, pos.longitude], { icon }).addTo(this.map);
    }

    this.map.fitBounds(bounds, { maxZoom: 18 });
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
