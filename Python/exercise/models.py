from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from sqlalchemy import func

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    coach_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    workouts = db.relationship('Workout', backref='user', lazy='dynamic', foreign_keys='Workout.user_id')
    assigned_programs = db.relationship('ProgramAssignment', backref='user', lazy='dynamic', foreign_keys='ProgramAssignment.user_id')
    notifications = db.relationship('Notification', backref='user', lazy='dynamic', foreign_keys='Notification.user_id')
    messages_sent = db.relationship('Message', backref='sender', lazy='dynamic', foreign_keys='Message.sender_id')
    messages_received = db.relationship('Message', backref='recipient', lazy='dynamic', foreign_keys='Message.recipient_id')

class Exercise(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    category = db.Column(db.String(50), nullable=False)
    description = db.Column(db.Text)
    video_url = db.Column(db.String(500))
    is_competition_lift = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Workout(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    exercise_id = db.Column(db.Integer, db.ForeignKey('exercise.id'), nullable=False)
    exercise = db.relationship('Exercise')
    sets = db.Column(db.Integer, nullable=False)
    reps = db.Column(db.Integer, nullable=False)
    weight = db.Column(db.Float, nullable=False)
    notes = db.Column(db.Text)
    date = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    program_workout_id = db.Column(db.Integer, db.ForeignKey('program_workout.id'), nullable=True)
    is_completed = db.Column(db.Boolean, default=False)

class WorkoutProgram(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    created_by = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    workouts = db.relationship('ProgramWorkout', backref='program', lazy='dynamic', cascade='all, delete-orphan')

class ProgramWorkout(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    program_id = db.Column(db.Integer, db.ForeignKey('workout_program.id'), nullable=False)
    day_number = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(100))
    exercises = db.relationship('ProgramExercise', backref='workout', lazy='dynamic', cascade='all, delete-orphan')

class ProgramExercise(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    program_workout_id = db.Column(db.Integer, db.ForeignKey('program_workout.id'), nullable=False)
    exercise_id = db.Column(db.Integer, db.ForeignKey('exercise.id'), nullable=False)
    exercise = db.relationship('Exercise')
    sets = db.Column(db.Integer, nullable=False)
    reps = db.Column(db.Integer, nullable=False)
    notes = db.Column(db.Text)
    order = db.Column(db.Integer, default=0)
    has_accommodating_resistance = db.Column(db.Boolean, default=False)
    accommodating_resistance_type = db.Column(db.String(100))

class ProgramAssignment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    program_id = db.Column(db.Integer, db.ForeignKey('workout_program.id'), nullable=False)
    program = db.relationship('WorkoutProgram')
    start_date = db.Column(db.Date, nullable=False)
    assigned_by = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow)

class Notification(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.String(50))
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    related_workout_id = db.Column(db.Integer, db.ForeignKey('workout.id'), nullable=True)

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    recipient_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    subject = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

def create_notification(user_id, message, notification_type, related_workout_id=None):
    try:
        notification = Notification(user_id=user_id, message=message, type=notification_type, related_workout_id=related_workout_id)
        db.session.add(notification)
        db.session.commit()
    except Exception:
        db.session.rollback()

def check_for_pr(user_id, exercise_id, weight):
    try:
        previous_max = db.session.query(func.max(Workout.weight)).filter(Workout.user_id == user_id, Workout.exercise_id == exercise_id).scalar()
        if previous_max is None or weight > previous_max:
            return True, previous_max
        return False, previous_max
    except Exception:
        return False, None

def get_workout_summary(user_id, current_workouts):
    try:
        from datetime import datetime, timedelta
        week_ago = datetime.utcnow() - timedelta(days=7)
        two_weeks_ago = datetime.utcnow() - timedelta(days=14)
        
        # Group current workout by exercise
        current_summary = {}
        for workout in current_workouts:
            ex_id = workout.exercise_id
            if ex_id not in current_summary:
                current_summary[ex_id] = {'exercise_name': workout.exercise.name, 'total_sets': 0, 'max_weight': 0, 'total_volume': 0}
            current_summary[ex_id]['total_sets'] += 1
            current_summary[ex_id]['max_weight'] = max(current_summary[ex_id]['max_weight'], workout.weight)
            current_summary[ex_id]['total_volume'] += workout.weight * workout.reps
        
        # Get previous week data
        prev_workouts = Workout.query.filter(
            Workout.user_id == user_id,
            Workout.date >= two_weeks_ago,
            Workout.date < week_ago
        ).all()
        
        prev_summary = {}
        for workout in prev_workouts:
            ex_id = workout.exercise_id
            if ex_id not in prev_summary:
                prev_summary[ex_id] = {'total_sets': 0, 'max_weight': 0, 'total_volume': 0}
            prev_summary[ex_id]['total_sets'] += 1
            prev_summary[ex_id]['max_weight'] = max(prev_summary[ex_id]['max_weight'], workout.weight)
            prev_summary[ex_id]['total_volume'] += workout.weight * workout.reps
        
        # Compare and build summary
        summary = []
        for ex_id, current in current_summary.items():
            prev = prev_summary.get(ex_id, {'total_sets': 0, 'max_weight': 0, 'total_volume': 0})
            
            weight_change = current['max_weight'] - prev['max_weight'] if prev['max_weight'] > 0 else 0
            volume_change = current['total_volume'] - prev['total_volume'] if prev['total_volume'] > 0 else 0
            sets_change = current['total_sets'] - prev['total_sets'] if prev['total_sets'] > 0 else 0
            
            summary.append({
                'exercise': current['exercise_name'],
                'sets': current['total_sets'],
                'max_weight': current['max_weight'],
                'total_volume': round(current['total_volume'], 1),
                'weight_change': weight_change,
                'volume_change': round(volume_change, 1),
                'sets_change': sets_change,
                'has_improvement': weight_change > 0 or volume_change > 0
            })
        
        return summary
    except Exception:
        return []