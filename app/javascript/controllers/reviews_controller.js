// app/javascript/controllers/reviews_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Reviews controller connected");
    this.scrollToBottom();
    this.element.addEventListener('reviews:updateScroll', () => this.updateScroll());
  }

  disconnect() {
    this.element.removeEventListener('reviews:updateScroll', () => this.updateScroll());
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight;
  }

  updateScroll() {
    setTimeout(() => {
      this.scrollToBottom();
    }, 100);
  }
}
