import csv
import random
import datetime

# --- Configurable row counts for T1
NUM_CLIENTS_T1 = 1000
NUM_OWNERS_T1  = 1000
NUM_CLIENT_CONTRACTS_T1 = 1500
NUM_OWNER_CONTRACTS_T1  = 1500
NUM_AD_CAMPAIGNS_T1     = 2000
NUM_MEDIUM_T1           = 500
NUM_VIEWSCLICKS_T1      = 3000

# For generating random dates:
def random_date(start_year=2025, end_year=2025):
    """
    Returns a random date in the given range (1 Jan start_year to 31 Dec end_year).
    """
    start_dt = datetime.date(start_year, 1, 1)
    end_dt   = datetime.date(end_year, 12, 31)
    delta = (end_dt - start_dt).days
    offset = random.randint(0, delta)
    return start_dt + datetime.timedelta(days=offset)

# 1) Generate Clients
def generate_clients_t1(num):
    first_names = ["Alice","Bob","Charlie","Diana","Eve","Frank","Gina","Henry","Ivy","Jack"]
    last_names  = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Wilson","Moore"]
    data = []
    for i in range(1, num+1):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        nip = random.randint(1000000000, 9999999999)  # 10-digit
        row = {
            "ClientID": i,
            "Name": fn,
            "Surname": ln,
            "NIP": nip
        }
        data.append(row)
    return data

# 2) Generate Owners
def generate_owners_t1(num):
    first_names = ["Marta","Maks","Luke","Hannah","Peter","Susan","George","Amy","Eric","Maria"]
    last_names  = ["Bell","Cook","Wood","Clark","Morales","Morgan","Reyes","Stewart","Cooper","Flores"]
    data = []
    for i in range(1, num+1):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        nip = random.randint(1000000000, 9999999999)
        data.append({
            "OwnerID": i,
            "Name": fn,
            "Surname": ln,
            "NIP": nip
        })
    return data

# 3) Generate ClientContracts
def generate_client_contracts_t1(num, max_client):
    data = []
    for i in range(1, num+1):
        cid = random.randint(1, max_client)
        start_dt = random_date(2025, 2025)
        duration_days = random.randint(30, 365)
        end_dt = start_dt + datetime.timedelta(days=duration_days)
        expense = round(random.uniform(1000, 20000), 2)
        click_profit = round(random.uniform(0.3, 5.0), 2)
        data.append({
            "CContractID": i,
            "ClientID": cid,
            "DateOfCommencement": start_dt.isoformat(),
            "DateOfExpiration": end_dt.isoformat(),
            "Duration": duration_days,
            "Expense": expense,
            "Click Profit": click_profit
        })
    return data

# 4) Generate OwnerContracts
def generate_owner_contracts_t1(num, max_owner):
    data = []
    for i in range(1, num+1):
        oid = random.randint(1, max_owner)
        start_dt = random_date(2025, 2025)
        duration_days = random.randint(30, 365)
        end_dt = start_dt + datetime.timedelta(days=duration_days)
        owner_revenue = round(random.uniform(500, 15000), 2)
        data.append({
            "OContractID": i,
            "OwnerID": oid,
            "DateOfCommencement": start_dt.isoformat(),
            "DateOfExpiration": end_dt.isoformat(),
            "Duration": duration_days,
            "Owner Revenue": owner_revenue
        })
    return data

# 5) Generate AdCampaigns
def generate_adcampaigns_t1(num, max_ccontract, max_ocontract):
    campaign_names = ["SummerSale","WinterDeal","HolidayPromo","Back2School","BlackFriday","EasterSpecial"]
    data = []
    for i in range(1, num+1):
        ccontract_id = random.randint(1, max_ccontract)
        ocontract_id = random.randint(1, max_ocontract)
        name = random.choice(campaign_names) + f"_{i}"
        start_dt = random_date(2025, 2025)
        days_long = random.randint(15, 90)
        end_dt = start_dt + datetime.timedelta(days=days_long)
        target_audience = random.randint(10000, 100000)
        # If end_dt is after "today", we say status=Active, else Completed
        # But T1 is "2025," so we can just do:
        status = "Active" if end_dt >= datetime.date(2025, 6, 30) else "Completed"
        data.append({
            "CampaignID": i,
            "OContractID": ocontract_id,
            "CContractID": ccontract_id,
            "Campaign Name": name,
            "Start Date": start_dt.isoformat(),
            "End Date": end_dt.isoformat(),
            "Target Audience": target_audience,
            "Status": status
        })
    return data

# 6) Generate Medium
def generate_mediums_t1(num):
    types = ["Website","MobileApp","Billboard","SocialMedia","VideoPlatform"]
    locations = ["Header","Sidebar","Footer","Pop-up","Interstitial","Feed","Stream"]
    data = []
    for i in range(1, num+1):
        t = random.choice(types)
        loc = random.choice(locations)
        data.append({
            "MediumID": i,
            "TypeOfMedium": t,
            "ad location": loc
        })
    return data

# 7) Generate ViewsClicks
def generate_views_clicks_t1(num, max_medium, max_ocontract):
    data = []
    for i in range(1, num+1):
        m_id = random.randint(1, max_medium)
        o_id = random.randint(1, max_ocontract)
        # BIT: 1=click, 0=view
        is_click = random.choice([0,1])
        user_id = random.randint(1, 500)  # hypothetical user from CSV
        # random date/time in 2025
        d = random_date(2025, 2025)
        # for simplicity, store "YYYY-MM-DD"
        data.append({
            "ViewClickID": i,
            "MediumID": m_id,
            "OContractID": o_id,
            "Views/Clicks": is_click,
            "UserID": user_id,
            "Timestamp": d.isoformat()
        })
    return data

def write_csv(filename, fieldnames, rows):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

def main():
    # 1) Generate T1 data
    clients = generate_clients_t1(NUM_CLIENTS_T1)
    owners = generate_owners_t1(NUM_OWNERS_T1)
    client_contracts = generate_client_contracts_t1(NUM_CLIENT_CONTRACTS_T1, NUM_CLIENTS_T1)
    owner_contracts  = generate_owner_contracts_t1(NUM_OWNER_CONTRACTS_T1, NUM_OWNERS_T1)
    ad_campaigns     = generate_adcampaigns_t1(NUM_AD_CAMPAIGNS_T1, NUM_CLIENT_CONTRACTS_T1, NUM_OWNER_CONTRACTS_T1)
    mediums          = generate_mediums_t1(NUM_MEDIUM_T1)
    views_clicks     = generate_views_clicks_t1(NUM_VIEWSCLICKS_T1, NUM_MEDIUM_T1, NUM_OWNER_CONTRACTS_T1)

    # 2) Write each table to CSV for T1
    write_csv("Client_T1.csv", ["ClientID","Name","Surname","NIP"], clients)
    write_csv("Owner_T1.csv", ["OwnerID","Name","Surname","NIP"], owners)
    write_csv("ClientContract_T1.csv",
              ["CContractID","ClientID","DateOfCommencement","DateOfExpiration","Duration","Expense","Click Profit"],
              client_contracts)
    write_csv("OwnerContract_T1.csv",
              ["OContractID","OwnerID","DateOfCommencement","DateOfExpiration","Duration","Owner Revenue"],
              owner_contracts)
    write_csv("AdCampaign_T1.csv",
              ["CampaignID","OContractID","CContractID","Campaign Name","Start Date","End Date","Target Audience","Status"],
              ad_campaigns)
    write_csv("Medium_T1.csv", ["MediumID","TypeOfMedium","ad location"], mediums)
    write_csv("ViewsClicks_T1.csv",
              ["ViewClickID","MediumID","OContractID","Views/Clicks","UserID","Timestamp"],
              views_clicks)

    print("T1 CSV files generated!")

if __name__ == "__main__":
    main()