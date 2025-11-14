#!/usr/env python3
import requests
from bs4 import BeautifulSoup
from lxml import etree
import time
import random 

# Start custom classes for exceptions
class TokenFailed(Exception): pass
class APIParseFailed(Exception): pass
class ProductNotFound(Exception): pass
class RetryLimitExceeded(Exception): pass
# End custom classes for exceptions

# Product List
ProdList = {
    "111127143": "dr-pepper-zero-8-x-330ml",
    "113327237": "sour-patch-kids-watermelon-130g"
}

def retry(exceptions, tries=3, delay=2):
    def decorator(func):
        def wrapper(*args, **kwargs):
            attempt = 0
            while attempt < tries:
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    attempt += 1
                    if attempt == tries:
                        raise RetryLimitExceeded(f"Retry limit exceeded: {e}")
                    time.sleep(delay)
        return wrapper
    return decorator

class API_Parser:
    def __init__(self, URL: str):
        self.URL = URL

    @retry((TokenFailed, APIParseFailed), tries=3, delay=2)
    def getHTML(self):
        URL = self.URL
        headers = {
            'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            'Accept-Language': 'en-US,en;q=0.5'
        }
        data = requests.get(URL, headers=headers)
        if data.status_code != 200:
            raise APIParseFailed()
        soup = BeautifulSoup(data.content, "html.parser")
        dom = etree.HTML(str(soup))
        try:
            Heading = dom.xpath('//*[@id="main"]/div/div[3]/div/div/h1')[0].text                    # Product Name
            Red_price = dom.xpath('//*[@id="main"]/div/div[3]/div/div/div[2]/span[1]')[0].text      # Reduced Price
            Norm_price = dom.xpath('//*[@id="main"]/div/div[3]/div/div/div[2]/span[2]')[0].text     # Normal Price
            print(f"{"Product":<10}: {Heading}\n{"Reduced":<10}: {Red_price}\n{"Normal":<10}: {Norm_price}")
        except IndexError:
            raise ProductNotFound("Product not found")
        except Exception as e:
            raise APIParseFailed(f"Error parsing HTML: {e}")

if __name__ == "__main__":
    try:
        productitem = list(ProdList.items())
        prodvalue = list(ProdList.values())
        prodkey = list(ProdList.keys())

        for prodkey, prodvalue in ProdList.items():
            url = f"https://groceries.morrisons.com/products/{prodvalue}/{prodkey}"
            
            time.sleep(random.random() * 4 + 2.5)
            print(url)
            API = API_Parser(URL=url)
            API.getHTML()
    except TokenFailed:
        print("Token failed")
    except APIParseFailed:
        print("API parse failed")
    except Exception as e:
        print(f"Unknown error: {e}")
    
