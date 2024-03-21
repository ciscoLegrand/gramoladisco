import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['aside', 'iconLeft', 'iconRight', 'link', 'title']

  connect() { 
    if (isNarrow === null) { 
      setCookie('asideState', JSON.stringify(false), 7)
    } else {
      this.loadState()
    }
  }

  loadState() {
    const isNarrow = JSON.parse(getCookie('asideState'));
    if (isNarrow) {
      this.applyNarrowState();
    }
  }
  
  saveState() {
    const isNarrow = this.asideTarget.classList.contains('lg:w-[4%]');
    setCookie('asideState', JSON.stringify(isNarrow), 7);
  }

  toggle(e) {
    e.preventDefault()
    this.decrease()
    this.saveState()
  }

  decrease() {
    this.applyNarrowState()
  }

  applyNarrowState() {
    this.asideTarget.classList.toggle('lg:w-2/12')
    this.asideTarget.classList.toggle('lg:w-[4%]')
    this.iconLeftTarget.classList.toggle('hidden')
    this.iconRightTarget.classList.toggle('hidden')

    this.linkTargets.forEach((link) => {
      link.classList.toggle('justify-start')
      link.classList.toggle('justify-center')
      link.classList.toggle('px-10', link.classList.contains('px-2'))
      link.classList.toggle('px-2', !link.classList.contains('px-2'))
    })
    this.titleTargets.forEach((title) => {
      title.classList.toggle('hidden')
    })
  }
}

// handle cookies
function setCookie(name, value, days) {
  let expires = "";
  if (days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    expires = "; expires=" + date.toUTCString();
  }
  document.cookie = name + "=" + (value || "")  + expires + "; path=/";
}

function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== '') {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      // ¿Esta cookie comienza con el nombre que queremos?
      if (cookie.substring(0, name.length + 1) === (name + '=')) {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}
