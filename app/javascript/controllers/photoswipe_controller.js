import { Controller } from "@hotwired/stimulus";
import PhotoSwipeLightbox from "photoswipe/lightbox";

export default class extends Controller {
  static targets = ["album"];
  connect() {
    // get all the images in the album
    console.log(this.albumTarget.dataset);
    const options = {
      gallery: '#gallery--zoom-transition',
      children: 'a',
      showHideAnimationType: 'zoom',
      bgOpacity: 0.85,
      pswpModule: () => import("photoswipe"),
    };

    const lightbox = new PhotoSwipeLightbox(options);
    lightbox.on('uiRegister', function() {
      lightbox.pswp.ui.registerElement({
        name: 'download-button',
        order: 8,
        isButton: true,
        tagName: 'a',

        html: {
          isCustomSVG: true,
          inner: '<path d="M20.5 14.3 17.1 18V10h-2.2v7.9l-3.4-3.6L10 16l6 6.1 6-6.1ZM23 23H9v2h14Z" id="pswp__icn-download"/>',
          outlineID: 'pswp__icn-download'
        },
    
        onInit: (el, pswp) => {
          el.addEventListener('click', (event) => {
            event.preventDefault();
            const blobId = pswp.currSlide.data.element.dataset.blobId;
            const albumId = pswp.currSlide.data.element.dataset.albumId;
            if (albumId && blobId) { // Asegúrate de que ambos IDs estén presentes
              const downloadUrl = `/albums/${albumId}/download_image?image_id=${blobId}`;
              window.location.href = downloadUrl;
            } else {
              console.error("Missing albumId or blobId");
            }
          });
        }
      });
    });
    lightbox.init();
  }
}
