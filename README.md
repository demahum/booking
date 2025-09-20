# Booking Calendar Application# README



A modern, bilingual booking calendar application built with Ruby on Rails 8.0 that allows users to select date ranges and save them to the database. The application features an intuitive calendar interface with full internationalization support for English and Bosnian languages.This README would normally document whatever steps are necessary to get the

application up and running.

## Features

Things you may want to cover:

### 🗓️ Interactive Calendar

- Clean, responsive calendar interface with month navigation* Ruby version

- Click and drag to select date ranges (single day to unlimited duration)

- Visual feedback with highlighted selection states* System dependencies

- Intuitive navigation with arrow controls and "Go To Today" button

* Configuration

### 🌍 Bilingual Support

- Full internationalization (i18n) with English and Bosnian languages* Database creation

- Language switcher in the top-right corner

- Session-based language preference storage* Database initialization

- Localized date formats, UI text, and error messages

- Default language: English* How to run the test suite



### 💾 Data Persistence* Services (job queues, cache servers, search engines, etc.)

- Save selected date ranges to SQLite database

- `DateRange` model with validation (start_date ≤ end_date)* Deployment instructions

- Flash message feedback for successful saves and errors

- Automatic form handling with Rails conventions* ...


### 📱 Responsive Design
- Mobile-first CSS approach with responsive breakpoints
- Touch-friendly interface for mobile devices
- Accessible color scheme with hover/focus states
- Clean, modern visual design

## Tech Stack

- **Framework**: Ruby on Rails 8.0.2
- **Ruby Version**: 3.4.6
- **Database**: SQLite3
- **Frontend**: ERB templates with custom CSS and JavaScript
- **Internationalization**: Rails I18n
- **Styling**: Custom CSS with responsive design
- **Server**: Puma

## Quick Start

### Prerequisites
- Ruby 3.4.6 or compatible version
- Rails 8.0.2
- SQLite3

### Installation

1. **Clone or download the project**
   ```bash
   cd /path/to/booking
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:setup
   rails db:migrate
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Open in browser**
   Navigate to `http://localhost:3000`

## Usage

### Calendar Navigation
- **Month Navigation**: Use left/right arrow buttons to navigate between months
- **Go To Today**: Click to return to the current month
- **Date Selection**: 
  - Click on a date to start selection
  - Click on another date to complete the range
  - Click elsewhere to start a new selection

### Language Switching
- Use the language switcher (EN/BS) in the top-right corner
- Language preference is stored in your session
- All UI elements and dates will be localized

### Saving Date Ranges
- Select your desired date range
- Click the "Save Range" (or "Sačuvaj Raspon") button
- Confirmation message will appear on successful save
- Validation ensures start date is not after end date

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb    # i18n and language switching
│   └── home_controller.rb          # calendar display and range saving
├── models/
│   └── date_range.rb              # date range model with validation
├── views/
│   ├── layouts/
│   │   └── application.html.erb    # main layout with language switcher
│   └── home/
│       └── index.html.erb         # interactive calendar interface
└── assets/
    └── stylesheets/
        └── application.css         # responsive calendar styling

config/
├── routes.rb                      # application routes
└── locales/
    ├── en.yml                     # English translations
    └── bs.yml                     # Bosnian translations

db/
├── migrate/
│   └── *_create_date_ranges.rb    # date ranges table migration
└── schema.rb                      # database schema
```

## API Endpoints

- `GET /` - Calendar homepage
- `GET /?month=X&year=Y` - Navigate to specific month
- `GET /?start_date=X&end_date=Y` - Display calendar with selected range
- `POST /save_range` - Save selected date range to database
- `GET /switch_locale/:locale` - Switch language (en/bs)
- `GET /reset_locale` - Reset to default language

## Database Schema

### DateRange Model
```ruby
# Table: date_ranges
id          :integer    (primary key)
start_date  :date       (required)
end_date    :date       (required)
created_at  :datetime
updated_at  :datetime

# Validation: start_date <= end_date
```

## Internationalization

The application supports full localization with the following translation keys:

### English (en.yml)
- Calendar headers (month names, weekdays)
- UI buttons and labels
- Flash messages
- Date formats
- Error messages

### Bosnian (bs.yml)
- Complete translation of all English content
- Localized date formats
- Cultural appropriate messaging

## Development

### Key Files to Modify

**Controllers**:
- `app/controllers/home_controller.rb` - Calendar logic and date handling
- `app/controllers/application_controller.rb` - i18n and language switching

**Views**:
- `app/views/home/index.html.erb` - Calendar interface and JavaScript
- `app/views/layouts/application.html.erb` - Layout and language switcher

**Models**:
- `app/models/date_range.rb` - Date range validation and persistence

**Styling**:
- `app/assets/stylesheets/application.css` - Calendar styling and responsive design

**Translations**:
- `config/locales/en.yml` - English translations
- `config/locales/bs.yml` - Bosnian translations

### Adding New Features

1. **New Languages**: Add locale files in `config/locales/` and update language switcher
2. **Additional Validations**: Modify `app/models/date_range.rb`
3. **UI Enhancements**: Update CSS in `app/assets/stylesheets/application.css`
4. **New Calendar Features**: Extend JavaScript in `app/views/home/index.html.erb`

## Testing

Run the test suite:
```bash
rails test
```

Test files are located in:
- `test/controllers/` - Controller tests
- `test/models/` - Model tests
- `test/fixtures/` - Test data

## Production Deployment

For production deployment:

1. **Environment Setup**
   ```bash
   RAILS_ENV=production rails db:migrate
   RAILS_ENV=production rails assets:precompile
   ```

2. **Database Configuration**
   Update `config/database.yml` for production database settings

3. **Security**
   - Set secure `SECRET_KEY_BASE`
   - Configure proper database credentials
   - Enable SSL if required

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is available as open source. Feel free to use, modify, and distribute as needed.

## Support

For issues or questions:
1. Check existing issues in the repository
2. Review the code in the key files listed above
3. Test with different browsers and screen sizes
4. Verify database migrations are up to date

---

**Built with ❤️ using Ruby on Rails 8.0**