# populate_db.py
import models, auth
from database import SessionLocal, engine, Base

Base.metadata.create_all(bind=engine)
db = SessionLocal()

locais = [
    {"name": "Big Ben", "country": "United Kingdom", "latitude": 51.510357, "longitude": -0.116773},
    {"name": "Eiffel Tower", "country": "France", "latitude": 48.858093, "longitude": 2.294694},
    {"name": "Berlin Wall", "country": "Germany", "latitude": 52.535152, "longitude": 13.390206},
    {"name": "Sagrada Familia", "country": "Spain", "latitude": 41.403706, "longitude": 2.173504},
    {"name": "Colosseum", "country": "Italy", "latitude": 41.890210, "longitude": 12.492231},
    {"name": "Statue of Liberty", "country": "United States", "latitude": 40.689247, "longitude": -74.044502},
    {"name": "Taj Mahal", "country": "India", "latitude": 27.175015, "longitude": 78.042155},
    {"name": "Great Wall of China", "country": "China", "latitude": 40.431908, "longitude": 116.570374},
    {"name": "Machu Picchu", "country": "Peru", "latitude": -13.163141, "longitude": -72.545894},
    {"name": "Sydney Opera House", "country": "Australia", "latitude": -33.856784, "longitude": 151.215296},
    {"name": "Petra", "country": "Jordan", "latitude": 30.328460, "longitude": 35.441397},
    {"name": "Chichen Itza", "country": "Mexico", "latitude": 20.684289, "longitude": -88.567781},
    {"name": "Christ the Redeemer", "country": "Brazil", "latitude": -22.951916, "longitude": -43.210487},
    {"name": "Machu Picchu", "country": "Peru", "latitude": -13.163141, "longitude": -72.545894},
    {"name": "Pisa Tower", "country": "Italy", "latitude": 43.7230, "longitude": 10.3966},
    {"name": "Copacabana Beach", "country": "Brazil", "latitude": -22.9719, "longitude": -43.1852},
    {"name": "Chichen Itza", "country": "Mexico", "latitude": 20.684289, "longitude": -88.567781},
    {"name": "Hyde Park", "country": "United Kingdom", "latitude": 51.5074, "longitude": -0.1657},
    {"name": "Lake Louise", "country": "Canada", "latitude": 51.4254, "longitude": -116.1775},
    {"name": "Christ the King", "country": "Portugal", "latitude": 38.6780, "longitude": -9.1670},
    {"name": "Lello Bookstore", "country": "Portugal", "latitude": 41.1466, "longitude": -8.6114},
    {"name": "Palace of Versailles", "country": "France", "latitude": 48.8049, "longitude": 2.1204},
    {"name": "Batalha Monastery", "country": "Portugal", "latitude": 39.6603, "longitude": -8.8243, "visited": {"path": "photos/mosteiro.jpg", "date": "2024-10-05"}},
    {"name": "Pena Palace", "country": "Portugal", "latitude": 38.7876, "longitude": -9.3900},
    {"name": "Aveiro Cathedral", "country": "Portugal", "latitude": 40.6401, "longitude": -8.6538, "visited": {"path": "photos/se.jpg", "date": "2024-10-01"}},
    {"name": "Louvre Museum", "country": "France", "latitude": 48.8606, "longitude": 2.3376},
    {"name": "Golden Gate Bridge", "country": "United States", "latitude": 37.8199, "longitude": -122.4783},
    {"name": "Neuschwanstein Castle", "country": "Germany", "latitude": 47.5576, "longitude": 10.7498},
    {"name": "La Sagrada Familia", "country": "Spain", "latitude": 41.4036, "longitude": 2.1744},
    {"name": "CN Tower", "country": "Canada", "latitude": 43.6426, "longitude": -79.3871},
    {"name": "Buenos Aires Obelisk", "country": "Argentina", "latitude": -34.6037, "longitude": -58.3816},
    {"name": "Tower Bridge", "country": "United Kingdom", "latitude": 51.5055, "longitude": -0.0754},
    {"name": "Louvre Abu Dhabi", "country": "United Arab Emirates", "latitude": 24.5333, "longitude": 54.3987},
    {"name": "Mount Fuji", "country": "Japan", "latitude": 35.3606, "longitude": 138.7274},
    {"name": "Grand Canyon", "country": "United States", "latitude": 36.1069, "longitude": -112.1129},
    {"name": "Buckingham Palace", "country": "United Kingdom", "latitude": 51.5014, "longitude": -0.1419},
    {"name": "Brandenburg Gate", "country": "Germany", "latitude": 52.5163, "longitude": 13.3777},
    {"name": "Museo del Prado", "country": "Spain", "latitude": 40.413780, "longitude": -3.692127},
    {"name": "Niagara Falls", "country": "Canada", "latitude": 43.0962, "longitude": -79.0377},
    {"name": "Matterhorn", "country": "Switzerland", "latitude": 45.9763, "longitude": 7.6586},
    {"name": "Château de Chambord", "country": "France", "latitude": 47.6169, "longitude": 1.5164},
    {"name": "Yellowstone National Park", "country": "United States", "latitude": 44.4280, "longitude": -110.5885},
    {"name": "Tower of London", "country": "United Kingdom", "latitude": 51.5081, "longitude": -0.0759},
    {"name": "Heidelberg Castle", "country": "Germany", "latitude": 49.4094, "longitude": 8.6915},
    {"name": "Park Güell", "country": "Spain", "latitude": 41.4145, "longitude": 2.1527},
    {"name": "Banff National Park", "country": "Canada", "latitude": 51.1784, "longitude": -115.5708},
    {"name": "Plaza de Mayo", "country": "Argentina", "latitude": -34.6037, "longitude": -58.3816},
]

for local in locais:
    db_local = models.Local(
        name=local['name'],
        country=local['country'],
        latitude=local['latitude'],
        longitude=local['longitude'],
    )
    db.add(db_local)

users = [
    {"username": "admin", "password": "admin"},
]

for user in users:
    db_user = models.User(
        username=user['username'],
        hashed_password=auth.get_password_hash(user['password']),
    )
    db.add(db_user)

db.commit()
db.close()
