"""
IRON FORGE GYM - Optimized Training Tracker Application
Installation: pip install flask flask-sqlalchemy pandas openpyxl werkzeug
Run: python app_optimized.py
Login: admin / admin123
"""

from flask import Flask
from models import db
from routes import create_routes
from token_auth import token_auth
import os

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'change-this-in-production')
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///ironforge_new.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['UPLOAD_FOLDER'] = 'uploads'
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
    
    db.init_app(app)
    token_auth.init_app(app)
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    create_routes(app)
    
    with app.app_context():
        try:
            db.create_all()
            
            # Import exercises from JSON if none exist
            from models import Exercise
            import json
            
            if Exercise.query.count() == 0:
                try:
                    with open('exercises.json', 'r') as f:
                        exercises_data = json.load(f)
                    for ex_data in exercises_data:
                        exercise = Exercise(
                            name=ex_data['name'],
                            category=ex_data['category'],
                            description=ex_data.get('description', ''),
                            is_competition_lift=ex_data.get('is_competition_lift', False)
                        )
                        db.session.add(exercise)
                    db.session.commit()
                except Exception as e:
                    print(f"Error importing exercises: {e}")
            
            # Create default admin user if not exists
            from models import User
            from werkzeug.security import generate_password_hash
            
            if not User.query.filter_by(username='admin').first():
                admin = User(
                    username='admin',
                    email='admin@ironforge.com',
                    password=generate_password_hash('admin123'),
                    is_admin=True
                )
                db.session.add(admin)
                db.session.commit()
        except Exception as e:
            print(f"Database initialization error: {e}")
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=False, host='0.0.0.0', port=5000)