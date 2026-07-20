import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // デバッグ用のログ出力
  connect() {
    console.log("Preview controller connected")
  }

  // デバッグ用
  disconnect() {
    console.log("Preview controller disconnected")
  }
}