# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.1.1/app/assets/javascripts/activestorage.esm.js"
pin "@rails/actiontext", to: "actiontext.js"
pin "trix"
pin "dropzone", to: "https://ga.jspm.io/npm:dropzone@6.0.0-beta.2/dist/dropzone.mjs"
pin "just-extend", to: "https://ga.jspm.io/npm:just-extend@5.1.1/index.esm.js"
pin "swiper", to: "https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs"
pin "photoswipe", to: "https://ga.jspm.io/npm:photoswipe@5.4.3/dist/photoswipe.esm.js"
pin "photoswipe/lightbox", to: "https://ga.jspm.io/npm:photoswipe@5.4.3/dist/photoswipe-lightbox.esm.js"
