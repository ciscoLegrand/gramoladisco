import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "button"];

  connect() {
    this.checkTruncation();
  }

  toggle() {
    this.contentTarget.classList.toggle('max-h-16');
    this.contentTarget.classList.toggle('max-h-none');
    this.buttonTarget.textContent = this.buttonTarget.textContent.trim() === "Leer más" ? "Leer menos" : "Leer más";
  }

  checkTruncation() {
    const characterLimit = 220

    if (this.contentTarget.innerText.length > characterLimit) {
      this.buttonTarget.classList.remove('hidden');
    } else {
      this.buttonTarget.classList.add('hidden');
    }
  }
}
