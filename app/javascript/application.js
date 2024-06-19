// Entry point for the build script in your package.json
import * as bootstrap from "bootstrap"
import jquery from "jquery"
import Rails from '@rails/ujs';

window.jQuery = jquery
window.$ = jquery

Rails.start();

document.addEventListener("DOMContentLoaded", function() {

  function toggleComments(selector, dataAttribute, displayStyle) {
    document.body.addEventListener("click", function(event) {
      if (event.target.closest(selector)) {
        var icon = event.target.closest(selector);
        var id = icon.getAttribute(dataAttribute);
        var comments = document.getElementById(id);

        if (comments.style.display === "none" || comments.style.display === "") {
          comments.style.display = displayStyle;
        } else {
          comments.style.display = "none";
        }
      }
    });
  }

  toggleComments(".show-comments", "data-comments", "flex");
  toggleComments(".show-comment-form", "data-comments-comment", "block");

});
