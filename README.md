💰 Money Tracker App (Flutter)

A modern personal finance management app built with Flutter, designed to help users track income, manage expenses, and control spending through a customizable budget system.

This application provides a simple yet powerful way to monitor financial activity with categorized transactions and budget limits.

----------------------------------------------------------------------------------------------------------

🚀 Features

💸 Expense Tracking
Record daily expenses with custom categories (e.g., electricity, rent, food)

💵 Income Management
Add multiple income sources (salary, freelance, business, etc.)

📊 Budget Control
Set maximum spending limits and monitor usage in real-time

🗂️ Custom Categories
Create and manage categories for both income and expenses

📈 Financial Overview
See total balance, income, and expenses at a glance

🔔 Budget Alerts (Optional Future Feature)
Get notified when nearing budget limits

-------------------------------------------------------------------------------------------------------------

🛠️ Tech Stack
Layer	Technology
Framework	Flutter
Language	Dart
State Mgmt	Provider / Riverpod (optional)
Storage	Local Storage (Hive / SharedPreferences / SQLite)
UI	Material Design

--------------------------------------------------------------------------------------------------------------

⚙️ Installation

Clone the repository:

git clone https://github.com/bayuaditya7/Flutter_Money_Tracker.git
cd Flutter_Money_Tracker

Install dependencies:

flutter pub get

Run the app:

flutter run

---------------------------------------------------------------------------------------------------------------

📱 Core Concepts
1. Budget System

Users can define a maximum spending limit

System tracks total expenses against the budget

Displays remaining balance and usage percentage

2. Transaction Management

Two types:

Income

Expense

Each transaction includes:

Amount

Category

Date

Notes (optional)

3. Category Management

Default categories:

Income: Salary, Freelance

Expense: Rent, Electricity, Food

Users can add custom categories dynamically

------------------------------------------------------------------------------------------------------------------

🎨 UI/UX Design

📱 Clean and minimal interface

🎯 Focus on usability and clarity

📊 Visual indicators for budget usage

🎨 Consistent color coding:

Green → Income

Red → Expense
