import requests
from pathlib import Path

# User data directory
USER_DATA_DIR = Path("user_data")

# Ensure the user data directory exists
USER_DATA_DIR.mkdir(parents=True, exist_ok=True)

# Function to load allergies for a user from file
def load_user_allergies(username):
    filepath = USER_DATA_DIR / f"{username}_allergies.txt"
    if filepath.exists():
        with open(filepath, 'r') as file:
            allergies = file.read().splitlines()
            return [allergy.lower() for allergy in allergies]
    return []

# Function to save allergies for a user to file
def save_user_allergies(username, allergies):
    filepath = USER_DATA_DIR / f"{username}_allergies.txt"
    with open(filepath, 'w') as file:
        for allergy in allergies:
            file.write(f"{allergy}\n")

# Function to handle user login
def login():
    username = input("Enter your username: ").strip()
    filepath = USER_DATA_DIR / f"{username}_allergies.txt"

    if filepath.exists():
        print("Login successful.")
        return username
    else:
        print("Username not found. Please sign up.")
        return signup()

# Function to handle user signup
def signup():
    username = input("Enter a new username: ").strip()
    filepath = USER_DATA_DIR / f"{username}_allergies.txt"

    if filepath.exists():
        print("Username already exists. Please log in.")
        return login()

    print("Please enter your allergies. Type 'done' when you are finished.")
    allergies = []

    while True:
        allergy = input("Enter an allergy: ").strip().lower()
        if allergy == 'done':
            break
        if allergy and allergy not in allergies:
            allergies.append(allergy)

    save_user_allergies(username, allergies)
    print("Signup successful.")
    return username

# Function to search for food and check ingredients for allergens using USDA API
def search_food_and_check_allergens(food_item, allergies_list, api_key):
    url = 'https://api.nal.usda.gov/fdc/v1/foods/search'
    params = {
        'query': food_item,
        'api_key': api_key
    }

    response = requests.get(url, params=params)

    if response.status_code == 200:
        data = response.json()
        found_allergen = False

        for food in data.get('foods', []):
            if 'ingredients' in food:
                food_ingredients = food['ingredients'].lower()

                for allergen in allergies_list:
                    if allergen in food_ingredients:
                        print(f"Warning: Contains allergen '{allergen}'")
                        found_allergen = True

        if not found_allergen:
            print("No allergens found in the ingredients.")
    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")

# Main logic for user interaction
if __name__ == "__main__":
    print("Welcome! Please log in or sign up.")
    action = input("Type 'login' to log in or 'signup' to sign up: ").strip().lower()

    if action == 'login':
        username = login()
    elif action == 'signup':
        username = signup()
    else:
        print("Invalid action.")
        exit()

    # Load the USDA API key (replace with your actual API key)
    api_key = 'n935f9TH7NtdKKaDzaEp9E2JlmomDd9qUoLuYMmx'

    while True:
        food_item = input("Enter the name of the food item you want to check (or type 'exit' to quit): ").strip()
        if food_item.lower() == 'exit':
            break

        if food_item:
            print(f"Checking for allergens in: {food_item}")
            allergies_list = load_user_allergies(username)
            if allergies_list:
                search_food_and_check_allergens(food_item, allergies_list, api_key)
            else:
                print("No allergies found. Please update your profile.")
        else:
            print("Invalid input. Please try again.")
