# Food to Go

Food to Go is a Flutter-based food ordering application for the University of San Jose-Recoletos (USJ-R). It allows users to create accounts and sign in using USJ-R email addresses through Supabase Authentication.

The application includes separate account types for regular users, food stall accounts, and administrators. Regular users can browse available food stalls, view menus, customize food orders, and manage their cart.

## Features

- **Supabase Authentication** – Sign in and create accounts using USJ-R email addresses.
- **Account Types** – Supports Regular, Food Stall, and Admin accounts.
- **Food Stall Browsing** – Browse available food stalls.
- **Food Menus** – View food products with descriptions and images.
- **Product Customization** – Select a product's purchase type, such as Solo or Meal.
- **Quantity Selection** – Choose the quantity of each product.
- **Shopping Cart** – Review selected products, purchase types, quantities, and prices.
- **Screen Navigation** – Navigate between the home screen, stall menus, product details, and cart.
- **SOLID Architecture** – Separates models, repositories, services, screens, and reusable widgets.

## Configure Supabase

1. Create or open your Supabase project.
2. In the project dashboard, copy the project URL and the publishable key (or legacy anon key).
3. Run the app with those values:

   ```powershell
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
   ```

   The Supabase URL and publishable key are client configuration values. Never put a Supabase service-role key in the app. For legacy projects, you can provide the anon key as `SUPABASE_PUBLISHABLE_KEY`.

4. To restrict account creation on the server as well as in the app, run [`supabase/allow_usjr_email.sql`](supabase/allow_usjr_email.sql) in the Supabase SQL Editor. Then open **Authentication → Hooks**, add a **Before User Created** hook, and select `public.allow_usjr_email`.
5. In **Authentication → Providers → Email**, enable email confirmations if you want users to verify that they can access their USJ-R inbox.

The app checks the email domain for both sign-up and sign-in. The database hook rejects non-USJ-R addresses on the server during account creation too.

## Account types

Account creation lets a user choose **Regular** (for students and professors) or **Food stall**. After login, the app opens the matching dashboard.

**Admin** accounts are assigned by the developer and cannot be selected at public sign-up.

When creating an account, the selected type is saved as Supabase user metadata:

- Regular: `{"account_type":"regular"}`
- Food stall: `{"account_type":"foodstall"}`

For admins, set the user's **app metadata** in the Supabase dashboard to `{"account_type":"admin"}`. This is separate from user metadata, which users can change.

Enforce data access with Supabase Row Level Security policies; client-side role selection is for directing users to the appropriate screen, not for granting secure access.

## Regular-user dashboard

The regular-user dashboard displays the available food stalls.

The current UI includes sample food stall listings:

- Waffle Time
- Burp'nGo
- Coffee Shop

Selecting a stall opens its dedicated menu screen. Users can browse available food products and select an item to view its details.

The current stall listings and menu products are provided through a mock repository. They are sample data for the UI and can later be connected to the Supabase database without needing to redesign the screens.

## Food stall menu and product selection

Each food stall has its own menu screen.

Users can:

1. Open a food stall from the regular-user dashboard.
2. Browse its available food products.
3. View product images and descriptions.
4. Open a product's detail screen.
5. Select a purchase type, such as **Solo** or **Meal**, when available.
6. Adjust the desired quantity.
7. Add the selected product to the cart.

The selected purchase type and quantity are tracked separately so that different versions of the same product can be represented correctly in the cart.

## Shopping cart

The shopping cart displays the products selected by the user.

It includes:

- Product name
- Selected purchase type
- Quantity
- Price and subtotal
- Cart total

Products with different purchase types are treated as separate cart entries.

The current cart uses in-memory state through the cart service. Cart contents are not yet permanently stored in Supabase, so they may reset when the application is restarted.

## Food-stall dashboard

The food-stall account has a separate dashboard intended for managing stall-related activities.

The current dashboard contains a placeholder for incoming orders. Connecting it to actual customer orders and Supabase database records is a future integration task.

## Project structure

The application separates its responsibilities into different folders to make the code easier to maintain and extend.

```text
lib/
│
├── main.dart
├── auth_screen.dart
├── home_screen.dart
├── account_type.dart
│
├── models/
│   ├── food_item.dart
│   ├── food_stall.dart
│   └── cart_item.dart
│
├── repositories/
│   ├── stall_repository.dart
│   └── mock_stall_repository.dart
│
├── services/
│   └── cart_service.dart
│
├── widgets/
│   └── food_image.dart
│
└── screens/
    ├── stall_menu_screen.dart
    ├── product_detail_screen.dart
    └── cart_screen.dart
```

### Folder responsibilities

- **models/** – Contains the data structures for food items, food stalls, and cart entries.
- **repositories/** – Handles retrieving food stall and menu information. The mock repository currently supplies sample data.
- **services/** – Contains application services, including cart management.
- **widgets/** – Contains reusable UI components, such as food images.
- **screens/** – Contains the individual screens for stall menus, product details, and the shopping cart.
- **main.dart** – Initializes the application and its dependencies.
- **auth_screen.dart** – Handles user authentication.
- **home_screen.dart** – Displays the appropriate home dashboard.
- **account_type.dart** – Contains account-type definitions and related role handling.

## Architecture and design principles

The application uses a separation-of-concerns approach to keep its components organized.

It also follows the SOLID principles:

- **Single Responsibility Principle (SRP)** – Models, repositories, services, and screens have separate responsibilities.
- **Open/Closed Principle (OCP)** – New food stalls and products can be added through the repository without requiring major changes to the UI.
- **Liskov Substitution Principle (LSP)** – Repository implementations can be substituted as long as they follow the repository contract.
- **Interface Segregation Principle (ISP)** – Components depend on the operations they need rather than unrelated functionality.
- **Dependency Inversion Principle (DIP)** – Screens depend on repository abstractions instead of directly depending on the mock data implementation.

## Current implementation and future integration

The current implementation combines Supabase Authentication with a sample food-ordering interface.

| Component | Current implementation |
|---|---|
| User authentication | Supabase Auth |
| Email restriction | USJ-R email validation |
| Account types | Regular, Food Stall, Admin |
| Food stall listings | Mock repository |
| Food menus | Sample data |
| Product selection | Functional UI |
| Purchase types | Solo and Meal |
| Quantity selection | Functional UI |
| Shopping cart | In-memory cart service |
| Order processing | Not yet connected to Supabase |
| Incoming food-stall orders | Placeholder |

### Future improvements

- Connect food stall listings and menu products to Supabase.
- Store cart information and customer orders in the database.
- Implement order submission and order confirmation.
- Allow food stall accounts to manage their menus.
- Allow food stall accounts to receive and update incoming orders.
- Implement administrator management features.
- Configure Supabase Row Level Security policies for secure data access.

**Note:** Existing Supabase authentication and account-type functionality should be retained when adding these features. The current UI and mock repository are intended to extend the application, not replace its existing authentication or database integration.