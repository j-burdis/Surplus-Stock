# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript", under: "javascript"
pin "orders", to: "orders.js"
pin "address", to: "address.js"
# pin "flatpickr", to: "https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.js"
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/flatpickr.js"
