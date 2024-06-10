// Entry point for the build script in your package.json
import * as bootstrap from "bootstrap"
import jquery from "jquery"
import Rails from '@rails/ujs';

window.jQuery = jquery
window.$ = jquery

Rails.start();
