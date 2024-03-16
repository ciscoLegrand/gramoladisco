import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "button", "wrapper"];

  connect() {
    this.checkTruncation()
    this.readMoreText = this.buttonTarget.dataset.readMoreText;
    this.readLessText = this.buttonTarget.dataset.readLessText;
  }

  toggle() {
    this.contentTarget.classList.toggle('max-h-24');
    this.contentTarget.classList.toggle('max-h-none');
    this.wrapperTarget.classList.toggle('h-80');
    this.wrapperTarget.classList.toggle('max-h-80');
    if (this.buttonTarget.textContent.trim() === this.readMoreText) {
      this.buttonTarget.textContent = this.readLessText;
    } else {
      this.buttonTarget.textContent = this.readMoreText;
    }
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
