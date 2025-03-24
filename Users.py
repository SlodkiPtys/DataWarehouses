import csv
import random
from datetime import datetime

# -----------------------------
# 1. Define T1 and T2
# -----------------------------
T1_DATE = datetime(2024, 2, 20)
T2_DATE = datetime(2025, 3, 24)

# Example data pools to make user data look "realistic"
FIRST_NAMES = [
    "John", "Jane", "Michael", "Emily", "Robert", "Jessica", "David", "Emma", "Daniel", "Olivia"
]
LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", "Rodriguez", "Wilson"
]
EMAIL_DOMAINS = ["gmail.com", "yahoo.com", "outlook.com", "example.org", "testmail.com"]
LOCATIONS = ["New York", "Los Angeles", "London", "Berlin", "Warsaw", "Madrid", "Sydney", "Tokyo"]
GENDERS = ["Male", "Female", "Other"]
POSSIBLE_INTERESTS = [
    "Technology", "Cooking", "Travel", "Sports", "Music",
    "Art", "Fitness", "Gaming", "Finance", "Movies"
]

# -----------------------------
# 2. Helper Functions
# -----------------------------
def generate_email(first_name, last_name):
    """Generate an email address from given first/last name and a random domain."""
    domain = random.choice(EMAIL_DOMAINS)
    email = f"{first_name.lower()}.{last_name.lower()}@{domain}"
    return email

def random_interests(k=3):
    """Return a random list of 'k' distinct interests from POSSIBLE_INTERESTS."""
    return ";".join(random.sample(POSSIBLE_INTERESTS, k))

def generate_t1_users(num_users=700):
    """Generate a list of user dictionaries for T1 with calculated age based on birth year."""
    data_t1 = []
    for i in range(1, num_users + 1):
        fn = random.choice(FIRST_NAMES)
        ln = random.choice(LAST_NAMES)
        email = generate_email(fn, ln)
        gender = random.choice(GENDERS)
        location = random.choice(LOCATIONS)
        interests = random_interests(k=random.randint(1, 3))
        birth_year = random.randint(1954, 2006)  # so they are 18-70 in 2024
        age = T1_DATE.year - birth_year

        row = {
            "UserID": i,
            "E-mail": email,
            "Gender": gender,
            "Location": location,
            "Interests": interests,
            "BirthYear": birth_year,
            "Age": age
        }
        data_t1.append(row)
    return data_t1

def write_csv(filename, fieldnames, rows):
    """Write a list of dicts (rows) to a CSV file."""
    with open(filename, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

def read_csv(filename):
    """Read a CSV into a list of dictionaries."""
    with open(filename, mode="r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader)

# -----------------------------
# 3. Main Flow
# -----------------------------
if __name__ == "__main__":
    # Generate T1 data (700 users)
    t1_users = generate_t1_users(num_users=700)
    fieldnames = ["UserID", "E-mail", "Gender", "Location", "Interests", "BirthYear", "Age"]

    # Write T1 CSV
    write_csv("user_ad_interactions_T1.csv", fieldnames, t1_users)
    print("Generated user_ad_interactions_T1.csv with ~700 rows.")

    # Load T1
    t1_data_loaded = read_csv("user_ad_interactions_T1.csv")

    # Convert numeric fields if needed
    for row in t1_data_loaded:
        row["UserID"] = int(row["UserID"])
        row["Age"] = int(row["Age"])
        row["BirthYear"] = int(row["BirthYear"])

    # Optional: Update location/interests for some T1 users to simulate changes by T2
    for user in t1_data_loaded:
        if random.random() < 0.25:
            user["Location"] = random.choice(LOCATIONS)
            user["Interests"] = random_interests(k=random.randint(2, 4))

    # Create T2 users by copying T1 and updating age
    t2_users = []
    for user in t1_data_loaded:
        user_copy = user.copy()
        birth_year = user_copy["BirthYear"]
        user_copy["Age"] = T2_DATE.year - birth_year
        t2_users.append(user_copy)

    # Add new users at T2 to reach ~1000 total
    new_users_count = 300
    last_user_id = max(u["UserID"] for u in t1_data_loaded)

    for i in range(1, new_users_count + 1):
        new_id = last_user_id + i
        fn = random.choice(FIRST_NAMES)
        ln = random.choice(LAST_NAMES)
        email = generate_email(fn, ln)
        gender = random.choice(GENDERS)
        location = random.choice(LOCATIONS)
        interests = random_interests(k=random.randint(1, 3))
        birth_year = random.randint(1955, 2007)
        age = T2_DATE.year - birth_year

        new_user = {
            "UserID": new_id,
            "E-mail": email,
            "Gender": gender,
            "Location": location,
            "Interests": interests,
            "BirthYear": birth_year,
            "Age": age
        }
        t2_users.append(new_user)

    # Write T2 CSV
    write_csv("user_ad_interactions_T2.csv", fieldnames, t2_users)
    print(f"Generated user_ad_interactions_T2.csv with {len(t2_users)} rows (~1000).")
