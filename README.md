The sample exchange rates app

# Requirements

- Xcode 10
- swiftlint (optional). Details in `Scripts/lint.sh`

# Assumptions and dependencies

- Precision and rounding are limited to the `Double` type. For better accuracy `Decimal` number must be used.
This can be adjusted in the  `ExchangeRate.Rate`

- Supported currencies: 
The application can handle a subset of the ISO 4217 currencies supported by the current locale.
Other currencies can be added to the `CurrencyFactory`.
Due to the API limitations, only part of the supported currencies is displayed on the UI. This is controlled by  `UserPreferences.availableCurrencies`



# Project structure

All app source files are split into a few main parts:

-  `Core` - generic code that can be reused in other apps
- `App` -  code that specific to the app domain and used  app-wide
- Other folders - code related to the concrete part of the app
