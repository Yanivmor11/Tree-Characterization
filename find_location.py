import requests
import time

def get_land_type(lat, lon):
    # הוספנו zoom=18 בסוף כדי לרדת לרזולוציה של בניין ספציפי
    url = f"https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lon}&format=json&zoom=18"
    
    headers = {
        'User-Agent': 'TreeMappingApp_FinalProject/1.0 yanivmor111222@gmail.com'
    }

    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        
        land_class = data.get('class', 'unknown')
        land_type = data.get('type', 'unknown')
        
        # שולפים גם את הכתובת כדי להבין בדיוק מה יש שם
        address_details = data.get('address', {})
        
        return f"Class: {land_class}, Type: {land_type} | Details: {address_details}"
    else:
        return f"Error: {response.status_code}"

# מריצים עם השהייה של שנייה וחצי בין קריאה לקריאה
print(get_land_type(32.097, 34.774))
#time.sleep(1.5)
#print(get_land_type(32.0644701, 34.8716377))
#time.sleep(1.5)
#print(get_land_type(32.048044, 34.8266564))