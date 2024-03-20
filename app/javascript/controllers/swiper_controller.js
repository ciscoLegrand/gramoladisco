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
        // Mobile (Small devices)
        640: {
          slidesPerView: 1,
          spaceBetween: 10,
        },
        // Tablet (Medium devices)
        768: {
          slidesPerView: 2,
          spaceBetween: 20,
        },
        // 2XL (Large devices)
        1536: {
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