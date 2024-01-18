import { Controller } from "@hotwired/stimulus"
import Swiper from 'swiper'

export default class extends Controller {
  static targets = [  "opinions" ]

  connect() {
    this.opinionSlider = new Swiper(this.opinionsTarget, {
      height:'300px',
      loop:true,
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },
      breakpoints: {
        640: {
          slidesPerView: 1,
          spaceBetween: 10,
        },
        768: {
          slidesPerView: 2,
          spaceBetween: 20,
        },
        1243: {
          slidesPerView: 3,
          spaceBetween: 30,
        },
      },
    });
  }

  disconnect() {
    this.opinionSlider.destroy()
    this.opinionSlider = undefined
  }
}