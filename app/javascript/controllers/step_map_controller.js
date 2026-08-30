import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    word: String,
  };

  connect() {
    this.map = L.map(this.element).setView(
      [this.latitudeValue, this.longitudeValue],
      18,
    );

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 20,
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);

    const icon = L.divIcon({
      className: "",
      html: `
        <div
          class="
            relative flex h-12 w-12 items-center justify-center
          "
        >
          <div
            class="
              relative z-10
              flex h-12 w-12 items-center justify-center
              rounded-full border-2 border-slate-700
              bg-white text-xl font-bold text-slate-800
              shadow-sm
            "
          >
            ${this.wordValue.charAt(0)}
          </div>

          <div
            class="
              absolute -bottom-1 left-1/2 z-20
              h-3 w-3
              -translate-x-1/2 rotate-45
              border-b-2 border-r-2 border-slate-700
              bg-white
            "
          ></div>
        </div>
      `,
      iconSize: [48, 54],
      iconAnchor: [24, 54],
    });

    L.marker(
      [this.latitudeValue, this.longitudeValue],
      { icon },
    ).addTo(this.map);
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
