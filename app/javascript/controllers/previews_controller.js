import { Controller } from "@hotwired/stimulus";
import Compressor from "compressorjs";

export default class extends Controller {
  static targets = ["input", "preview", "image"];

  disconnect() {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
    }
  }

  openFileSelector() {
    this.inputTarget.click();
  }

  async preview(e) {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
      this.objectUrl = null;
    }

    const file = e.target.files[0];

    if (!file) {
      this.removeImage();
      return;
    }

    const maxSizeOfBytes = 10 * 1024 * 1024; // 画像の最大サイズは10MB

    if (file.size > maxSizeOfBytes) {
      alert("画像のサイズは10MB以下にしてください");
      this.removeImage();
      return;
    }

    const allowedMimeType = ["image/jpeg", "image/png"];

    if (!allowedMimeType.includes(file.type)) {
      alert("PNGまたはJPEG形式のファイルを選択してください");
      this.removeImage();
      return;
    }

    try {
      const compressedFile = await this.compressImage(file);
      this.objectUrl = URL.createObjectURL(compressedFile);
      this.imageTarget.src = this.objectUrl;
      this.previewTarget.classList.remove("hidden");
      this.dispatch("file-selected");
    } catch (error) {
      console.error("画像の圧縮に失敗しました", error);
      alert("画像の処理に失敗しました。もう一度選択してください。");
      this.removeImage();
    }
  }

  async compressImage(file) {
    return new Promise((resolve, reject) => {
      new Compressor(file, {
        quality: 0.6,
        success(result) {
          console.log("圧縮前", {
            name: file.name,
            type: file.type,
            size: file.size,
          });

          console.log("圧縮後", {
            name: result.name,
            type: result.type,
            size: result.size,
          });

          resolve(result);
        },
        error(error) {
          reject(error);
        },
      });
    });
  }

  removeImage() {
    this.inputTarget.value = "";
    this.imageTarget.src = "";
    this.previewTarget.classList.add("hidden");
  }
}
