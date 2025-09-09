import CorePasswordToggler from "src/decidim/password_toggler";

class PasswordToggler extends CorePasswordToggler {
  init() {
    this.createControls();
    this.button.addEventListener("click", (evt) => {
      this.toggleVisibility(evt);
    });
  }
}

const initializeApiSecretToggler = () => {
  const apiUserPasswords = document.querySelectorAll("[data-controller='api-user-secret']");
  console.log(apiUserPasswords);
  apiUserPasswords.forEach((userPassword) => {
    new PasswordToggler(userPassword).init();
  })
}

document.addEventListener("DOMContentLoaded", () => {
  // Fix issue with the incorrect icons path for decidim-system.
  const iconsPath = window.Decidim.config.get("remixicon_path");
  window.Decidim.config.set("icons_path", iconsPath);

  initializeApiSecretToggler();
});
