import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdownContent", "openButton"]
  static values = { open: Boolean }

  connect() {
    this.openValue ? this.open() : this.close()
    window.addEventListener('keydown', this.closeWithKeyboard)
    window.addEventListener('click', this.closeWithClickOutside)
  }

  disconnect() {
    window.removeEventListener('keydown', this.closeWithKeyboard)
    window.removeEventListener('click', this.closeWithClickOutside)
  }

  open(e) {
    if (e) e.preventDefault()
    this.dropdownContentTarget.classList.remove('hidden')
    setTimeout(() => this.dropdownContentTarget.classList.remove('opacity-0'), 50)
    this.openValue = true
  }

  close(e) {
    if (e) e.preventDefault()
    this.dropdownContentTarget.classList.add('opacity-0')
    setTimeout(() => this.dropdownContentTarget.classList.add('hidden'), 300)
    this.openValue = false
  }

  closeWithKeyboard = (event) => {
    if (event.code === "Escape") {
      this.close()
    }
  }

  closeWithClickOutside = (event) => {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
