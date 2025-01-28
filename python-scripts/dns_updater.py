import requests
from typing import Union

# Spaceship API credentials
# API docs https://docs.spaceship.dev/#tag/DnsRecords/operation/saveRecords
# API manager https://www.spaceship.com/application/api-manager/
# Domains DNS info to check https://www.spaceship.com/application/advanced-dns-application/manage/valme.me/
API_KEY = ""
API_SECRET = ""
DOMAINS = [".me", ".xyz"]  # Your domains
TTL = 3600  # 1 hour TTL
BASE_URL = "https://spaceship.dev/api/v1"

HEADERS = {"X-API-Key": API_KEY, "X-API-Secret": API_SECRET, "Content-Type": "application/json"}


def get_public_ip():
    """Fetch the current public IP address with detailed logging."""
    try:
        print("⏳ Fetching public IP from api.ipify.org...")
        response = requests.get("https://api.ipify.org", timeout=10)
        response.raise_for_status()
        ip = response.text.strip()
        print(f"✅ Public IP found: {ip}")
        return ip
    except Exception as e:
        print(f"❌ Error fetching public IP: {str(e)}")
        return None


def get_existing_a_record(domain) -> Union[list, None]:
    """Find existing A record with enhanced error handling."""
    url = f"{BASE_URL}/dns/records/{domain}"
    print(f"\n🔍 Checking existing records for {domain}")
    print(f"   GET {url}")
    params = {"take": 100, "skip": 0}
    print(f"   Params: {params}")

    try:
        response = requests.get(url, headers=HEADERS, timeout=10, params=params)
        print(f"   Response status: {response.status_code}")

        if response.status_code != 200:
            print(f"   ❌ Failed to fetch records: {response.text}")
            return None

        records = response.json().get("items", [])
        print(f"   Found {len(records)} DNS records")
        # print(f"   Full response: {response.json()}")  # Debug entire response
        if not records:
            print("   ℹ️ No records found")
            return None
        return [record.get("address") for record in records]

    except Exception as e:
        print(f"   ❌ Error checking DNS records: {str(e)}")
        return None


def delete_dns_record(domain, record_ip):
    """Delete record with IP validation."""
    if not record_ip:
        print("   ⚠️ No record IP provided for deletion")
        return False

    url = f"{BASE_URL}/dns/records/{domain}"
    print(f"\n🗑️ Attempting to delete record {record_ip}")
    print(f"   DELETE {url}")
    payload = [{"type": "A", "address": record_ip, "name": "@"}]

    try:
        response = requests.delete(url, headers=HEADERS, json=payload, timeout=10)
        print(f"   Response status: {response.status_code}")

        if response.status_code in [200, 204]:
            print(f"   ✅ Successfully deleted record {record_ip}")
            return True

        print(f"   ❌ Delete failed: {response.text}")
        return False

    except Exception as e:
        print(f"   ❌ Delete error: {str(e)}")
        return False


def update_dns_record(domain, ip):
    """Update DNS record with comprehensive error handling."""
    print(f"\n🚀 Starting update process for {domain}")
    add_new_record = True
    existing_ips: list = get_existing_a_record(domain)

    if existing_ips is not None:
        for existing_ip in existing_ips:
            if existing_ip != ip:
                print(f"   🗑️ Non matching existing IP's {existing_ip} will be deleted")
                delete_dns_record(domain, existing_ip)
            elif existing_ip == ip:
                print(f"   🎯 IP {existing_ip} is already correct no need to add new one")
                add_new_record = False

    if add_new_record:
        url = f"{BASE_URL}/dns/records/{domain}"
        payload = {"force": True, "items": [{"type": "A", "name": "@", "address": ip, "ttl": TTL}]}

        print(f"\n🔄 Creating new A record for {domain}")
        print(f"   PUT {url}")
        print(f"   Payload: {payload}")

        try:
            response = requests.put(url, headers=HEADERS, json=payload, timeout=10)
            print(f"   Response status: {response.status_code}")

            if response.status_code in [200, 204]:
                print(f"   ✅ Successfully updated {domain} to {ip}")
                if response.content:
                    print(f"   Response content: {response.json()}")
            else:
                print(f"   ❌ Update failed: {response.text}")

        except Exception as e:
            print(f"   ❌ Update error: {str(e)}")


def main():
    print("\n" + "=" * 50)
    print(f"🚦 Starting DNS update for {', '.join(DOMAINS)}")
    print("=" * 50)

    public_ip = get_public_ip()

    if not public_ip:
        print("\n❌ Aborting due to missing public IP")
        return

    for domain in DOMAINS:
        print("\n" + "=" * 50)
        update_dns_record(domain, public_ip)

    print("\n" + "=" * 50)
    print("🏁 Update process completed")
    print("=" * 50)


if __name__ == "__main__":
    main()
