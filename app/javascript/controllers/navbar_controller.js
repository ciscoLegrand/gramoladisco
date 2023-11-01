import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainMenu", "categorySubmenu"]

  toggleMainMenu(e) {
    e.preventDefault()
    const menu = this.mainMenuTarget
    menu.classList.toggle('hidden')
  }

  toggleCatSubmenu(e) {
    e.preventDefault()
    const catMenu = this.categorySubmenuTarget
    catMenu.classList.toggle('hidden')
  }
}

