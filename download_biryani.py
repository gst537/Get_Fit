from icrawler.builtin import BingImageCrawler
import os

folder_path = os.path.join(os.getcwd(), 'TrainingData', 'Chicken Biryani')
os.makedirs(folder_path, exist_ok=True)

print("Starting download for Chicken Biryani...")
crawler = BingImageCrawler(storage={'root_dir': folder_path})
crawler.crawl(keyword='Chicken Biryani dish plate', max_num=40)
print("Done! Images downloaded to TrainingData/Chicken Biryani/")
