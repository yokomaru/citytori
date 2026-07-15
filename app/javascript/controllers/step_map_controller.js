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

    L.marker([this.latitudeValue, this.longitudeValue])
      .addTo(this.map)
      .bindPopup(this.wordValue, { autoClose: false })
      .openPopup();
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
