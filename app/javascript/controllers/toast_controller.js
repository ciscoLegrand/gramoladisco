import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.timeout = setTimeout(() => {
      this.close();
    }, this.data.get('timeout'));
  }

  close() {
    this.containerTarget.classList.add('toast-fade-out');
    setTimeout(() => {
      this.containerTarget.remove();
    }, 2000);
  }
}
