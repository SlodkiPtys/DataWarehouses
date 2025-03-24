import csv
from datetime import datetime, date, timedelta
import random

T2_DATE = date(2025, 3, 24)  # example "later" date

# Reusable read/write
def read_csv(filename):
    with open(filename, "r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def write_csv(filename, fieldnames, rows):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

def parse_date(dt_str):
    return datetime.strptime(dt_str, "%Y-%m-%d").date()

# Example function: if T2 >= expiration date => "finished," else "ongoing"
def contract_is_expired(exp_str):
    exp_dt = parse_date(exp_str)
    return (T2_DATE >= exp_dt)

def main():
    # 1) Client
    clients_t1 = read_csv("Client_T1.csv")
    # For T2, we won't force “expiration” of a client. Maybe we add new clients
    # Copy T1 data
    clients_t2 = list(clients_t1)
    max_client_id = max(int(c["ClientID"]) for c in clients_t1)
    # Add 2 new clients
    for i in range(1,3):
        new_id = max_client_id + i
        clients_t2.append({
            "ClientID": new_id,
            "Name": f"NewClient_{new_id}",
            "Surname": "T2Added",
            "NIP": random.randint(1000000000, 9999999999)
        })

    write_csv("Client_T2.csv", ["ClientID","Name","Surname","NIP"], clients_t2)

    # 2) Owner
    owners_t1 = read_csv("Owner_T1.csv")
    owners_t2 = list(owners_t1)
    max_owner_id = max(int(o["OwnerID"]) for o in owners_t1)
    # Add 2 new owners
    for i in range(1,3):
        new_id = max_owner_id + i
        owners_t2.append({
            "OwnerID": new_id,
            "Name": f"NewOwner_{new_id}",
            "Surname": "T2Added",
            "NIP": random.randint(1000000000, 9999999999)
        })
    write_csv("Owner_T2.csv", ["OwnerID","Name","Surname","NIP"], owners_t2)

    # 3) ClientContract
    cc_t1 = read_csv("ClientContract_T1.csv")
    for row in cc_t1:
        # parse the date fields
        row["CContractID"] = int(row["CContractID"])
        row["ClientID"]    = int(row["ClientID"])
        row["Duration"]    = int(row["Duration"])
        # optionally do something if T2 >= expiration
        if contract_is_expired(row["DateOfExpiration"]):
            # no "status" field, but we could add a new field or just accept it's ended
            # For example, let's just shorten "Duration" to show it's completed
            row["Duration"] = 0

    # Add a new contract or two for T2
    cc_t2 = list(cc_t1)
    max_cc_id = max(r["CContractID"] for r in cc_t1)
    for i in range(1,3):
        new_cc_id = max_cc_id + i
        client_id  = random.randint(1, len(clients_t2))  # pick from T2 clients
        start_dt   = date(2025, 9, 1) + timedelta(days=random.randint(0,30))
        duration   = random.randint(60, 300)
        end_dt     = start_dt + timedelta(days=duration)
        expense    = round(random.uniform(1000,20000),2)
        clickp     = round(random.uniform(0.5,5.0),2)
        cc_t2.append({
            "CContractID": new_cc_id,
            "ClientID": client_id,
            "DateOfCommencement": start_dt.isoformat(),
            "DateOfExpiration": end_dt.isoformat(),
            "Duration": duration,
            "Expense": expense,
            "Click Profit": clickp
        })

    write_csv("ClientContract_T2.csv",
              ["CContractID","ClientID","DateOfCommencement","DateOfExpiration","Duration","Expense","Click Profit"],
              cc_t2)

    # 4) OwnerContract
    oc_t1 = read_csv("OwnerContract_T1.csv")
    for row in oc_t1:
        row["OContractID"] = int(row["OContractID"])
        row["OwnerID"]     = int(row["OwnerID"])
        row["Duration"]    = int(row["Duration"])
        # if T2 >= expiration => ended
        if contract_is_expired(row["DateOfExpiration"]):
            row["Duration"] = 0

    oc_t2 = list(oc_t1)
    max_oc_id = max(r["OContractID"] for r in oc_t1)
    # Add new ones
    for i in range(1,3):
        new_id = max_oc_id + i
        owner_id = random.randint(1, len(owners_t2))
        start_dt = date(2025, 8, 1) + timedelta(days=random.randint(0,60))
        duration = random.randint(30,365)
        end_dt   = start_dt + timedelta(days=duration)
        rev      = round(random.uniform(500,15000),2)
        oc_t2.append({
            "OContractID": new_id,
            "OwnerID": owner_id,
            "DateOfCommencement": start_dt.isoformat(),
            "DateOfExpiration": end_dt.isoformat(),
            "Duration": duration,
            "Owner Revenue": rev
        })
    write_csv("OwnerContract_T2.csv",
              ["OContractID","OwnerID","DateOfCommencement","DateOfExpiration","Duration","Owner Revenue"],
              oc_t2)

    # 5) AdCampaign
    ac_t1 = read_csv("AdCampaign_T1.csv")
    for row in ac_t1:
        row["CampaignID"] = int(row["CampaignID"])
        row["OContractID"] = int(row["OContractID"])
        row["CContractID"] = int(row["CContractID"])
        row["Target Audience"] = int(row["Target Audience"])
        # Check if T2 >= End Date => "Completed"
        end_date = parse_date(row["End Date"])
        if T2_DATE >= end_date:
            row["Status"] = "Completed"
        else:
            row["Status"] = "Active"

    ac_t2 = list(ac_t1)
    max_camp_id = max(r["CampaignID"] for r in ac_t1)
    # Add new T2 campaigns
    for i in range(1,3):
        new_id = max_camp_id + i
        # pick existing new or old OwnerContract, ClientContract
        rand_oc = random.randint(1, len(oc_t2))
        rand_cc = random.randint(1, len(cc_t2))
        start_dt = T2_DATE + timedelta(days=random.randint(0,15))
        days_len = random.randint(30,120)
        end_dt   = start_dt + timedelta(days=days_len)
        t_aud    = random.randint(20000,100000)
        ac_t2.append({
            "CampaignID": new_id,
            "OContractID": rand_oc,
            "CContractID": rand_cc,
            "Campaign Name": f"T2Campaign_{new_id}",
            "Start Date": start_dt.isoformat(),
            "End Date": end_dt.isoformat(),
            "Target Audience": t_aud,
            "Status": "Active"
        })
    write_csv("AdCampaign_T2.csv",
              ["CampaignID","OContractID","CContractID","Campaign Name","Start Date","End Date","Target Audience","Status"],
              ac_t2)

    # 6) Medium
    medium_t1 = read_csv("Medium_T1.csv")
    medium_t2 = list(medium_t1)
    # maybe we add 1 new medium
    max_mid = max(int(m["MediumID"]) for m in medium_t1)
    new_id = max_mid + 1
    medium_t2.append({
        "MediumID": new_id,
        "TypeOfMedium": "ARApp",
        "ad location": "Hologram"
    })
    write_csv("Medium_T2.csv", ["MediumID","TypeOfMedium","ad location"], medium_t2)

    # 7) ViewsClicks
    vc_t1 = read_csv("ViewsClicks_T1.csv")
    # parse them
    for row in vc_t1:
        row["ViewClickID"] = int(row["ViewClickID"])
        row["MediumID"]    = int(row["MediumID"])
        row["OContractID"] = int(row["OContractID"])
        row["Views/Clicks"] = int(row["Views/Clicks"])
        row["UserID"]      = int(row["UserID"])

    vc_t2 = list(vc_t1)
    max_vc_id = max(r["ViewClickID"] for r in vc_t1)
    # Add new logs for T2 date range
    for i in range(1, 10):
        new_id = max_vc_id + i
        m_id = random.randint(1, len(medium_t2))  # pick from T2 mediums
        oc_id = random.randint(1, len(oc_t2))     # from T2 owner contracts
        is_click = random.choice([0,1])
        user_id = random.randint(1,500)
        # Timestamp in T2 timeframe
        new_dt = T2_DATE + timedelta(days=random.randint(0,15))
        vc_t2.append({
            "ViewClickID": new_id,
            "MediumID": m_id,
            "OContractID": oc_id,
            "Views/Clicks": is_click,
            "UserID": user_id,
            "Timestamp": new_dt.isoformat()
        })

    write_csv("ViewsClicks_T2.csv",
              ["ViewClickID","MediumID","OContractID","Views/Clicks","UserID","Timestamp"],
              vc_t2)

    print("T2 CSV files generated with updates + new rows!")

if __name__ == "__main__":
    main()
