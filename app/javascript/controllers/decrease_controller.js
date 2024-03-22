import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['aside', 'iconLeft', 'iconRight', 'link', 'title']

  connect() {
    this.initializeState();
  }

  initializeState() {
    // Usar 'false' como valor por defecto si el item no existe en localStorage
    let isNarrow = localStorage.getItem('asideState') === 'true';
    this.asideTarget.setAttribute('aria-expanded', String(!isNarrow));
    if (isNarrow) {
      this.applyNarrowState();
    } else {
      this.applyWideState();
    }
  }

  toggle(e) {
    e.preventDefault();
    this.asideTarget.classList.contains('lg:w-2/12') ? this.applyNarrowState() : this.applyWideState();
    this.saveState();
  }

  applyNarrowState() {
    this.asideTarget.classList.remove('lg:w-2/12');
    this.asideTarget.classList.add('lg:w-[4%]');
    this.asideTarget.setAttribute('aria-expanded', 'false');
    this.iconLeftTarget.classList.add('hidden');
    this.iconRightTarget.classList.remove('hidden');
    this.linkTargets.forEach(link => {
      link.classList.add('justify-center');
      link.classList.remove('justify-start');
      link.classList.add('px-2', link.classList.contains('px-10'));
    })
    this.titleTargets.forEach(title => {
      title.classList.add('hidden');
    });
  }

  applyWideState() {
    this.asideTarget.classList.add('lg:w-2/12');
    this.asideTarget.classList.remove('lg:w-[4%]');
    this.asideTarget.setAttribute('aria-expanded', 'true');
    this.iconLeftTarget.classList.remove('hidden');
    this.iconRightTarget.classList.add('hidden');
    this.titleTargets.forEach(title => {
      title.classList.remove('hidden');
    });
    this.linkTargets.forEach(link => {
      link.classList.remove('justify-center');
      link.classList.add('justify-start');
      link.classList.remove('px-10', link.classList.contains('px-2'));
    })
  }

  saveState() {
    const isNarrow = this.asideTarget.classList.contains('lg:w-[4%]');
    // Convertir el booleano a string para guardar en localStorage
    localStorage.setItem('asideState', String(isNarrow));
  }
}
