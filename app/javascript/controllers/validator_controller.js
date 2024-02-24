import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "subject", "submit", "required"];
  connect() {
    this.requiredFieldsCompleted();
    console.log('requiredds', this.requiredTargets);
  }

  requiredFieldsCompleted() {
    let allValid = true;
    this.requiredTargets.forEach((field) => {
      if (field.value.length === 0) {
        allValid = false;
        return;
      } else {
        const isValid = this.validate({ currentTarget: field });
        if (!isValid) {
          allValid = false;
          return;
        }
      }
    })
    this.enableSubmitButton(allValid);
  }
  
  validate(event) {
    const target = event.currentTarget;
    const type = target.dataset.validatorType;
    switch (type) {
      case "length":
        return this.lengthValidator(event);
      case "email":
        return this.emailValidator(event);
      default:
        return false;
    }
  }

  lengthValidator(event) {
    const target = event.currentTarget;
    const minLength = parseInt(target.dataset.validatorMinlengthValue, 10);
    const maxLength = parseInt(target.dataset.validatorMaxlengthValue, 10);
    const value = target.value;
    if (value.length < minLength || value.length > maxLength) {
      target.classList.add("border", "border-red-500", "focus:border-red-500","text-red-900");
      return false;
    } else {
      target.classList.remove("border", "border-red-500", "focus:border-red-500",  "text-red-900");
      return true;
    }
  }

  emailValidator(event) {
    const target = event.currentTarget;
    const value = target.value;
    const emailRegex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-zA-Z]{2,}\b/;
    if (emailRegex.test(value)) {
      target.classList.remove("border", "border-red-500", "focus:border-red-500", "text-red-900", "font-bold");
      return true;
    } else {
      target.classList.add("border", "border-red-500", "focus:border-red-500", "text-red-900");
      return false;
    }
  }

  enableSubmitButton(enable) {
    if (enable) {
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("bg-gray-300", "cursor-not-allowed");
    } else {
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("bg-gray-300", "cursor-not-allowed");
    }
  }
}