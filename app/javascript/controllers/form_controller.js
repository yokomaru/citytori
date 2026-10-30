import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="form"
export default class extends Controller {
  static targets = ["word"];

  finishConfirmEndWithN(event) {
    const endChar = this.wordTarget.value.replace(/ー+$/, "").slice(-1);

    if (endChar === "ん") {
      if (
        !window.confirm(
          "「ん」で終わることばです。この記録を保存して、散歩をおしまいにしますか？",
        )
      ) {
        event.preventDefault();
      }
    }
  }
}
