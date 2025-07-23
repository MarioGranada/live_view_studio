import {AsYouType} from "../../vendor/libphonenumber-js.min";

const PhoneInputHook = {
  mounted() {
    this.el.addEventListener("input", () => {
      this.el.value = new AsYouType("US").input(this.el.value);
    });
  },
};

export default PhoneInputHook;
