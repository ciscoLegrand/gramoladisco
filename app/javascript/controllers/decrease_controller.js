import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['aside', 'iconLeft', 'iconRight', 'link']
  static values = { icon: String }
  conect() {
    console.log('decrease controller conect')
  }

  decrease(e) {
    e.preventDefault()
    console.log('decrease')
    this.asideTarget.classList.toggle('lg:w-2/12')
    this.asideTarget.classList.toggle('lg:w-1/12')
    this.iconLeftTarget.classList.toggle('hidden')
    this.iconRightTarget.classList.toggle('hidden')

    this.linkTargets.forEach((link) => {
      link.classList.toggle('hidden')
    })
  }
}