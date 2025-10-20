import jwt
from datetime import datetime, timedelta
from functools import wraps
from flask import request, jsonify, current_app, session, redirect, url_for, flash
from models import User, db

class TokenAuth:
    def __init__(self, app=None):
        self.app = app
        if app:
            self.init_app(app)
    
    def init_app(self, app):
        app.config.setdefault('JWT_SECRET_KEY', 'your-secret-key-change-in-production')
        app.config.setdefault('JWT_ACCESS_TOKEN_EXPIRES', timedelta(hours=2))
        app.config.setdefault('JWT_REFRESH_TOKEN_EXPIRES', timedelta(days=7))
    
    def generate_tokens(self, user_id):
        """Generate access and refresh tokens"""
        now = datetime.utcnow()
        
        access_payload = {
            'user_id': user_id,
            'exp': now + current_app.config['JWT_ACCESS_TOKEN_EXPIRES'],
            'iat': now,
            'type': 'access'
        }
        
        refresh_payload = {
            'user_id': user_id,
            'exp': now + current_app.config['JWT_REFRESH_TOKEN_EXPIRES'],
            'iat': now,
            'type': 'refresh'
        }
        
        access_token = jwt.encode(access_payload, current_app.config['JWT_SECRET_KEY'], algorithm='HS256')
        refresh_token = jwt.encode(refresh_payload, current_app.config['JWT_SECRET_KEY'], algorithm='HS256')
        
        return access_token, refresh_token
    
    def verify_token(self, token, token_type='access'):
        """Verify and decode token"""
        try:
            payload = jwt.decode(token, current_app.config['JWT_SECRET_KEY'], algorithms=['HS256'])
            if payload.get('type') != token_type:
                return None
            return payload
        except jwt.ExpiredSignatureError:
            return 'expired'
        except jwt.InvalidTokenError:
            return None
    
    def get_current_user(self):
        """Get current user from token"""
        token = session.get('access_token')
        if not token:
            return None
        
        payload = self.verify_token(token)
        if not payload:
            return None
        
        if payload == 'expired':
            # Try to refresh token
            refresh_token = session.get('refresh_token')
            if refresh_token:
                refresh_payload = self.verify_token(refresh_token, 'refresh')
                if refresh_payload and refresh_payload != 'expired':
                    # Generate new tokens
                    new_access, new_refresh = self.generate_tokens(refresh_payload['user_id'])
                    session['access_token'] = new_access
                    session['refresh_token'] = new_refresh
                    payload = self.verify_token(new_access)
                else:
                    self.logout()
                    return None
            else:
                self.logout()
                return None
        
        try:
            user = User.query.get(payload['user_id'])
            return user
        except Exception:
            return None
    
    def login_user(self, user):
        """Login user and set tokens"""
        access_token, refresh_token = self.generate_tokens(user.id)
        session['access_token'] = access_token
        session['refresh_token'] = refresh_token
        session['user_id'] = user.id
        session['username'] = user.username
        session['is_admin'] = user.is_admin
    
    def logout(self):
        """Clear all session data"""
        session.clear()

# Global instance
token_auth = TokenAuth()

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        user = token_auth.get_current_user()
        if not user:
            flash('Please log in to access this page', 'error')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        user = token_auth.get_current_user()
        if not user:
            flash('Please log in to access this page', 'error')
            return redirect(url_for('login'))
        if not user.is_admin:
            flash('Admin access required', 'error')
            return redirect(url_for('dashboard'))
        return f(*args, **kwargs)
    return decorated_function

def client_only(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        user = token_auth.get_current_user()
        if not user:
            flash('Please log in to access this page', 'error')
            return redirect(url_for('login'))
        if user.is_admin:
            flash('Client access only', 'error')
            return redirect(url_for('dashboard'))
        return f(*args, **kwargs)
    return decorated_function