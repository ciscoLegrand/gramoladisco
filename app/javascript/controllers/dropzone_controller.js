import { Controller } from "@hotwired/stimulus"

import Dropzone from "dropzone";

Dropzone.autoDiscover = false;

export default class extends Controller {
  static targets = ["input"];
  static values = { album: String };
  connect() {
    console.log("Connecting Dropzone Controller");

    let albumId = this.albumValue;
    console.log("Album ID: ", albumId);
    this.dropzone = new Dropzone(this.element, {
      url: `/admin/images?album_id=${albumId}`,
      paramName: "images",
      maxFilesize: 25, // MB
      parallelUploads: 5,
      uploadMultiple: true,
      addRemoveLinks: true,
      previewsContainer: ".dropzone-previews",
      clickable: true,

      init: function() {
        this.on("success", function(file, response) {
          file.previewElement.setAttribute('data-id', response.file_id);
          console.log("File uploaded successfully: ", response);
        
          if (response.error) {
            var node;
            var message = response.error;
            file.previewElement.classList.add("dz-error");
            var _ref = file.previewElement.querySelectorAll("[data-dz-errormessage]");
            for (var _i = 0, _len = _ref.length; _i < _len; _i++) {
              node = _ref[_i];
              node.textContent = message;
            }
          }
        });
        
        this.on("removedfile", function(file) {
          console.log("File removed: ", file);
          var fileId = file.previewElement.getAttribute('data-id');

          var deleteUrl = `/admin/images/${fileId}?album_id=${albumId}`;

          fetch(deleteUrl, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
          })
          .then(response => response.json())
          .then(data => {
            console.log('File removed on server: ', data);
          })
          .catch((error) => {
            console.error('Error:', error);
          });
        });
      },
    });
  }

  disconnect() {
    console.log("Disconnecting Dropzone Controller");
    this.dropzone.destroy();
  }
}
