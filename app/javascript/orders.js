document.addEventListener("turbo:load", function () {
  const cardNumberInput = document.getElementById("card-number");
  const expiryDateInput = document.getElementById("expiry-date");
  const cvvInput = document.getElementById("cvv");

  function allowOnlyNumericInput(event) {
    const allowedKeys = [
      "Backspace",
      "ArrowLeft",
      "ArrowRight",
      "Tab",
      "Delete",
    ]; // Keys for navigation and deletion
    const isNumberKey = event.key >= "0" && event.key <= "9";
    const isAllowedKey = allowedKeys.includes(event.key);

    if (!isNumberKey && !isAllowedKey) {
      event.preventDefault();
    }
  }

  // Format card number (adds space every 4 digits)
  cardNumberInput?.addEventListener("input", (e) => {
    let value = e.target.value.replace(/\D+/g, ""); // Remove spaces
    value = value.slice(0, 16); // Limit to 16 digits
    value = value.replace(/(\d{4})(?=\d)/g, "$1 "); // Add space every 4 digits
    e.target.value = value.trim();
  });

  cardNumberInput?.addEventListener("keydown", allowOnlyNumericInput)

  // Format expiry date (adds '/' after MM)
  expiryDateInput?.addEventListener("input", (e) => {
    let value = e.target.value.replace(/[^0-9]/g, ""); // Remove existing slashes
    value = value.slice(0, 4); // Limit to 4 digits (MMYY)
    if (value.length > 2) {
      value = `${value.slice(0, 2)}/${value.slice(2)}`;
    }
    e.target.value = value;
  });

  expiryDateInput?.addEventListener("keydown", allowOnlyNumericInput);

  // Limit CVV to 4 digits
  cvvInput?.addEventListener("input", (e) => {
    let value = e.target.value.replace(/[^0-9]/g, ""); // Remove non-numeric characters
    value = value.slice(0, 4); // Limit to 4 digits
    e.target.value = value;
  });

  cvvInput?.addEventListener("keydown", allowOnlyNumericInput);
});
