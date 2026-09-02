import os
import time
from duckduckgo_search import DDGS
from fastdownload import download_url
from concurrent.futures import ThreadPoolExecutor

machines = [
    "Treadmill", "Leg Press Machine", "Smith Machine", 
    "Cable Crossover Machine", "Lat Pulldown Machine",
    "Seated Row Machine", "Leg Extension Machine", 
    "Leg Curl Machine", "Chest Press Machine",
    "Pec Deck Machine", "Hack Squat Machine", 
    "Assault Bike", "Rowing Machine",
    "Preacher Curl Bench", "Calf Raise Machine"
]

base_dir = os.path.expanduser("~/Desktop/GymMachineDataset")
os.makedirs(base_dir, exist_ok=True)

def download_image(url, dest):
    try:
        download_url(url, dest, show_progress=False, timeout=5)
        return True
    except Exception:
        return False

def scrape_machine(machine):
    print(f"Scraping images for: {machine}...")
    machine_dir = os.path.join(base_dir, machine)
    os.makedirs(machine_dir, exist_ok=True)
    
    with DDGS() as ddgs:
        results = list(ddgs.images(
            f"{machine} gym equipment",
            max_results=30
        ))
        
    count = 0
    urls = [r['image'] for r in results if r.get('image')]
    
    def process_url(idx_url):
        idx, url = idx_url
        ext = url.split('.')[-1][:4]
        if ext.lower() not in ['jpg', 'jpeg', 'png']:
            ext = 'jpg'
        dest = os.path.join(machine_dir, f"{machine.replace(' ', '_')}_{idx}.{ext}")
        if download_image(url, dest):
            return 1
        return 0

    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(process_url, enumerate(urls)))
        
    print(f"✅ Downloaded {sum(results)} images for {machine}")

for machine in machines:
    scrape_machine(machine)
    time.sleep(2) # be nice to API

print(f"\n🎉 All done! Dataset is at {base_dir}")
