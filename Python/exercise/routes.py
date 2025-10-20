from flask import Flask, render_template, request, redirect, url_for, session, flash
from werkzeug.security import check_password_hash
from datetime import datetime, timedelta, date
from sqlalchemy.orm import joinedload
from models import *
from token_auth import login_required, admin_required, client_only, token_auth

def create_routes(app):
    
    @app.context_processor
    def inject_notification_count():
        user = token_auth.get_current_user()
        if user:
            try:
                count = Notification.query.filter_by(user_id=user.id, is_read=False).count()
                return dict(unread_notifications_count=count)
            except Exception:
                return dict(unread_notifications_count=0)
        return dict(unread_notifications_count=0)

    @app.route('/')
    def index():
        user = token_auth.get_current_user()
        if user:
            return redirect(url_for('dashboard'))
        return redirect(url_for('login'))

    @app.route('/login', methods=['GET', 'POST'])
    def login():
        if request.method == 'POST':
            try:
                username = request.form['username']
                password = request.form['password']
                user = User.query.filter_by(username=username).first()
                if user and check_password_hash(user.password, password):
                    token_auth.login_user(user)
                    flash('Login successful', 'success')
                    return redirect(url_for('dashboard'))
                else:
                    flash('Invalid username or password', 'error')
            except Exception:
                flash('Login error occurred', 'error')
        return render_template('login.html')

    @app.route('/logout')
    def logout():
        token_auth.logout()
        flash('Logged out successfully', 'success')
        return redirect(url_for('login'))

    @app.route('/dashboard')
    @login_required
    def dashboard():
        user = token_auth.get_current_user()
        if user.is_admin:
            return redirect(url_for('coach_dashboard'))
        else:
            return redirect(url_for('client_dashboard'))

    @app.route('/notifications')
    @login_required
    def notifications():
        try:
            user = token_auth.get_current_user()
            notifs = Notification.query.filter_by(user_id=user.id).order_by(Notification.created_at.desc()).all()
            return render_template('notifications.html', notifications=notifs)
        except Exception:
            flash('Error loading notifications', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/notifications/<int:notification_id>/read', methods=['POST'])
    @login_required
    def mark_notification_read(notification_id):
        try:
            user = token_auth.get_current_user()
            notif = Notification.query.get_or_404(notification_id)
            if notif.user_id == user.id:
                notif.is_read = True
                db.session.commit()
        except Exception:
            db.session.rollback()
        return redirect(url_for('notifications'))

    @app.route('/notifications/mark_all_read', methods=['POST'])
    @login_required
    def mark_all_notifications_read():
        try:
            user = token_auth.get_current_user()
            Notification.query.filter_by(user_id=user.id, is_read=False).update({'is_read': True})
            db.session.commit()
            flash('All notifications marked as read', 'success')
        except Exception:
            db.session.rollback()
            flash('Error updating notifications', 'error')
        return redirect(url_for('notifications'))

    @app.route('/messages')
    @login_required
    def messages():
        try:
            user = token_auth.get_current_user()
            received = Message.query.options(joinedload(Message.sender)).filter_by(recipient_id=user.id).order_by(Message.created_at.desc()).all()
            sent = Message.query.options(joinedload(Message.recipient)).filter_by(sender_id=user.id).order_by(Message.created_at.desc()).all()
            coach = User.query.get(user.coach_id) if user.coach_id else None
            clients = User.query.filter_by(is_admin=False).all() if user.is_admin else []
            return render_template('messages.html', received_messages=received, sent_messages=sent, coach=coach, clients=clients)
        except Exception:
            flash('Error loading messages', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/messages/send', methods=['POST'])
    @login_required
    def send_message():
        try:
            user = token_auth.get_current_user()
            message = Message(
                sender_id=user.id, 
                recipient_id=int(request.form['recipient_id']), 
                subject=request.form['subject'], 
                message=request.form['message']
            )
            db.session.add(message)
            db.session.commit()
            flash('Message sent successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error sending message', 'error')
        return redirect(url_for('messages'))

    @app.route('/messages/<int:message_id>/read', methods=['POST'])
    @login_required
    def mark_message_read(message_id):
        try:
            user = token_auth.get_current_user()
            msg = Message.query.get_or_404(message_id)
            if msg.recipient_id == user.id:
                msg.is_read = True
                db.session.commit()
        except Exception:
            db.session.rollback()
        return redirect(url_for('messages'))

    # CLIENT ROUTES
    @app.route('/client/dashboard')
    @client_only
    def client_dashboard():
        try:
            user = token_auth.get_current_user()
            user_id = user.id
            assignments = ProgramAssignment.query.filter_by(user_id=user_id).all()
            today = date.today()
            today_workouts = []
            
            for assignment in assignments:
                days_since_start = (today - assignment.start_date).days
                day_number = (days_since_start % 7) + 1
                program_workout = ProgramWorkout.query.filter_by(program_id=assignment.program_id, day_number=day_number).first()
                if program_workout:
                    today_workouts.append({'program': assignment.program, 'workout': program_workout, 'assignment': assignment})
            
            recent_workouts = Workout.query.filter_by(user_id=user_id).order_by(Workout.date.desc()).limit(5).all()
            # Count unique workout sessions (by date) not individual exercises
            from sqlalchemy import func
            total_workouts = db.session.query(func.count(func.distinct(func.date(Workout.date)))).filter_by(user_id=user_id).scalar()
            week_ago = datetime.utcnow() - timedelta(days=7)
            workouts_this_week = db.session.query(func.count(func.distinct(func.date(Workout.date)))).filter(Workout.user_id == user_id, Workout.date >= week_ago).scalar()
            
            # Get current 1RMs for competition lifts
            current_1rms = {}
            comp_lifts = ['Squat', 'Bench Press', 'Deadlift']
            for lift_name in comp_lifts:
                exercise = Exercise.query.filter_by(name=lift_name, is_competition_lift=True).first()
                if exercise:
                    latest_workout = Workout.query.filter_by(user_id=user_id, exercise_id=exercise.id).order_by(Workout.date.desc()).first()
                    if latest_workout:
                        if latest_workout.reps == 1:
                            current_1rm = latest_workout.weight
                        else:
                            current_1rm = latest_workout.weight * (1 + latest_workout.reps / 30.0)
                        current_1rms[lift_name.replace(' Press', '')] = round(current_1rm, 1)
            
            # Get strength progress data for competition lifts (best set per day)
            competition_exercises = Exercise.query.filter_by(is_competition_lift=True).all()
            strength_data = {}
            for exercise in competition_exercises:
                # Group by date and get best set (highest estimated 1RM) per day
                from sqlalchemy import func, desc
                workouts = db.session.query(Workout).filter_by(user_id=user_id, exercise_id=exercise.id).order_by(Workout.date).all()
                
                if workouts:
                    # Group by date and find best set per day
                    daily_best = {}
                    for w in workouts:
                        date_key = w.date.date()
                        if w.reps == 1:
                            e1rm = float(w.weight)
                        else:
                            e1rm = float(w.weight) * (1 + w.reps / 30.0)
                        
                        if date_key not in daily_best or e1rm > daily_best[date_key]['e1rm']:
                            daily_best[date_key] = {
                                'workout': w,
                                'e1rm': e1rm
                            }
                    
                    # Sort by date and extract data
                    sorted_dates = sorted(daily_best.keys())
                    strength_data[exercise.name] = {
                        'dates': [d.strftime('%Y-%m-%d') for d in sorted_dates],
                        'weights': [float(daily_best[d]['workout'].weight) for d in sorted_dates],
                        'reps': [daily_best[d]['workout'].reps for d in sorted_dates],
                        'estimated_1rm': [round(daily_best[d]['e1rm'], 1) for d in sorted_dates]
                    }
            
            return render_template('client_dashboard.html', 
                                 today_workouts=today_workouts, 
                                 recent_workouts=recent_workouts, 
                                 total_workouts=total_workouts, 
                                 workouts_this_week=workouts_this_week,
                                 strength_data=strength_data,
                                 current_1rms=current_1rms)
        except Exception:
            flash('Error loading dashboard', 'error')
            return redirect(url_for('login'))

    @app.route('/client/programs')
    @client_only
    def client_programs():
        try:
            user = token_auth.get_current_user()
            assignments = ProgramAssignment.query.filter_by(user_id=user.id).all()
            return render_template('client_programs.html', assignments=assignments)
        except Exception:
            flash('Error loading programs', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/client/workouts')
    @client_only
    def client_workouts():
        try:
            user = token_auth.get_current_user()
            workouts = Workout.query.options(joinedload(Workout.exercise)).filter_by(user_id=user.id).order_by(Workout.date.desc()).all()
            return render_template('client_workouts.html', workouts=workouts)
        except Exception:
            flash('Error loading workouts', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/workout/start/<int:program_workout_id>')
    @login_required
    def start_workout(program_workout_id):
        try:
            program_workout = ProgramWorkout.query.get_or_404(program_workout_id)
            return render_template('start_workout.html', program_workout=program_workout)
        except Exception:
            flash('Error loading workout', 'error')
            return redirect(url_for('dashboard'))
    
    @app.route('/workout/summary')
    @login_required
    def workout_summary():
        try:
            summary_data = session.pop('workout_summary', None)
            if not summary_data:
                flash('No workout summary available', 'error')
                return redirect(url_for('client_dashboard'))
            return render_template('workout_summary.html', **summary_data)
        except Exception:
            flash('Error loading workout summary', 'error')
            return redirect(url_for('client_dashboard'))
    
    @app.route('/token/status')
    @login_required
    def token_status():
        """Debug route to check token status"""
        user = token_auth.get_current_user()
        access_token = session.get('access_token')
        refresh_token = session.get('refresh_token')
        
        status = {
            'user': user.username if user else 'None',
            'has_access_token': bool(access_token),
            'has_refresh_token': bool(refresh_token)
        }
        
        if access_token:
            try:
                import jwt
                payload = jwt.decode(access_token, current_app.config['JWT_SECRET_KEY'], algorithms=['HS256'])
                from datetime import datetime
                status['access_expires'] = datetime.fromtimestamp(payload['exp']).strftime('%Y-%m-%d %H:%M:%S')
            except Exception as e:
                status['access_error'] = str(e)
        
        return f"<pre>{status}</pre>"

    @app.route('/workout/complete/<int:program_workout_id>', methods=['POST'])
    @login_required
    def complete_workout(program_workout_id):
        try:
            user = token_auth.get_current_user()
            user_id = user.id
            exercise_count = int(request.form['exercise_count'])
            coach_id = user.coach_id
            pr_count = 0
            comp_lift_achievements = []
            completed_workouts = []
            
            for i in range(1, exercise_count + 1):
                exercise_id = int(request.form[f'exercise_id_{i}'])
                sets = int(request.form[f'sets_{i}'])
                notes = request.form.get(f'notes_{i}', '')
                exercise = Exercise.query.get(exercise_id)
                
                # Process each set individually
                for set_num in range(1, sets + 1):
                    reps_key = f'reps_{i}_{set_num}'
                    weight_key = f'weight_{i}_{set_num}'
                    
                    if reps_key not in request.form or weight_key not in request.form:
                        continue
                        
                    reps = int(request.form[reps_key])
                    weight = float(request.form[weight_key])
                    
                    workout = Workout(
                        user_id=user_id, 
                        exercise_id=exercise_id, 
                        sets=1,  # Each entry is one set
                        reps=reps, 
                        weight=weight, 
                        notes=f"Set {set_num}: {notes}" if notes else f"Set {set_num}", 
                        program_workout_id=program_workout_id, 
                        is_completed=True
                    )
                    db.session.add(workout)
                    db.session.flush()
                    completed_workouts.append(workout)
                    
                    is_pr, prev_max = check_for_pr(user_id, exercise_id, weight)
                    if is_pr:
                        pr_count += 1
                        if coach_id:
                            if prev_max:
                                message = f"{user.username} hit a new PR on {exercise.name}: {weight}kg (previous: {prev_max}kg)!"
                            else:
                                message = f"{user.username} logged their first {exercise.name}: {weight}kg!"
                            create_notification(coach_id, message, 'pr_achieved', workout.id)
                    
                    if exercise.is_competition_lift:
                        comp_lift_achievements.append({'exercise': exercise.name, 'weight': weight, 'is_pr': is_pr})
            
            db.session.commit()
            
            # Generate workout summary
            workout_summary = get_workout_summary(user_id, completed_workouts)
            
            if coach_id:
                total_sets = sum(int(request.form[f'sets_{i}']) for i in range(1, exercise_count + 1))
                create_notification(coach_id, f"{user.username} completed a workout: {exercise_count} exercises, {total_sets} sets", 'workout_complete')
            
            if comp_lift_achievements and coach_id:
                for achievement in comp_lift_achievements:
                    msg = f"{user.username} logged {achievement['exercise']}: {achievement['weight']}kg"
                    if achievement['is_pr']:
                        msg += " (NEW PR!)"
                    create_notification(coach_id, msg, 'competition_lift')
            
            # Store summary in session for display
            session['workout_summary'] = {
                'summary': workout_summary,
                'pr_count': pr_count,
                'total_exercises': len(workout_summary)
            }
                
        except Exception:
            db.session.rollback()
            flash('Error completing workout', 'error')
            
        return redirect(url_for('workout_summary'))

    # COACH ROUTES
    @app.route('/coach/dashboard')
    @admin_required
    def coach_dashboard():
        try:
            user = token_auth.get_current_user()
            clients = User.query.filter_by(is_admin=False).all()
            recent_workouts = Workout.query.options(
                joinedload(Workout.user), 
                joinedload(Workout.exercise)
            ).order_by(Workout.date.desc()).limit(10).all()
            unread_messages = Message.query.filter_by(recipient_id=user.id, is_read=False).count()
            return render_template('coach_dashboard.html', 
                                 clients=clients, 
                                 recent_workouts=recent_workouts, 
                                 unread_messages=unread_messages)
        except Exception:
            flash('Error loading dashboard', 'error')
            return redirect(url_for('login'))

    @app.route('/coach/clients')
    @admin_required
    def coach_clients():
        try:
            clients = User.query.filter_by(is_admin=False).all()
            return render_template('coach_clients.html', clients=clients)
        except Exception:
            flash('Error loading clients', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/coach/client/<int:client_id>')
    @admin_required
    def view_client(client_id):
        try:
            client = User.query.get_or_404(client_id)
            workouts = Workout.query.options(joinedload(Workout.exercise)).filter_by(user_id=client_id).order_by(Workout.date.desc()).limit(20).all()
            programs = WorkoutProgram.query.all()
            return render_template('view_client.html', client=client, workouts=workouts, programs=programs, today=date.today())
        except Exception:
            flash('Error loading client', 'error')
            return redirect(url_for('coach_clients'))

    @app.route('/assign_program', methods=['POST'])
    @admin_required
    def assign_program():
        try:
            user = token_auth.get_current_user()
            assignment = ProgramAssignment(
                user_id=int(request.form['user_id']),
                program_id=int(request.form['program_id']),
                start_date=datetime.strptime(request.form['start_date'], '%Y-%m-%d').date(),
                assigned_by=user.id
            )
            db.session.add(assignment)
            db.session.commit()
            flash('Program assigned successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error assigning program', 'error')
        return redirect(request.referrer or url_for('coach_clients'))

    # Add missing routes for program and exercise management
    @app.route('/coach/programs')
    @admin_required
    def coach_programs():
        try:
            programs = WorkoutProgram.query.all()
            return render_template('coach_programs.html', programs=programs)
        except Exception:
            flash('Error loading programs', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/coach/exercises')
    @admin_required
    def coach_exercises():
        try:
            exercises = Exercise.query.all()
            return render_template('coach_exercises.html', exercises=exercises)
        except Exception:
            flash('Error loading exercises', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/admin_panel')
    @admin_required
    def admin_panel():
        try:
            users = User.query.all()
            return render_template('admin_panel.html', users=users)
        except Exception:
            flash('Error loading admin panel', 'error')
            return redirect(url_for('dashboard'))

    @app.route('/create_exercise', methods=['POST'])
    @admin_required
    def create_exercise():
        try:
            exercise = Exercise(
                name=request.form['name'],
                category=request.form['category'],
                description=request.form.get('description', ''),
                video_url=request.form.get('video_url', ''),
                is_competition_lift=bool(request.form.get('is_competition_lift'))
            )
            db.session.add(exercise)
            db.session.commit()
            flash('Exercise created successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error creating exercise', 'error')
        return redirect(url_for('coach_exercises'))

    @app.route('/create_program', methods=['POST'])
    @admin_required
    def create_program():
        try:
            user = token_auth.get_current_user()
            program = WorkoutProgram(
                name=request.form['name'],
                description=request.form.get('description', ''),
                created_by=user.id
            )
            db.session.add(program)
            db.session.commit()
            flash('Program created successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error creating program', 'error')
        return redirect(url_for('coach_programs'))

    @app.route('/create_user', methods=['POST'])
    @admin_required
    def create_user():
        try:
            current_user = token_auth.get_current_user()
            from werkzeug.security import generate_password_hash
            is_client = bool(request.form.get('is_client'))
            is_admin = bool(request.form.get('is_admin')) if not is_client else False
            
            user = User(
                username=request.form['username'],
                email=request.form['email'],
                password=generate_password_hash(request.form['password']),
                is_admin=is_admin,
                coach_id=current_user.id if not is_admin else None
            )
            db.session.add(user)
            db.session.commit()
            
            if is_client:
                flash('Client added successfully', 'success')
                return redirect(url_for('coach_clients'))
            else:
                flash('User created successfully', 'success')
                return redirect(url_for('admin_panel'))
        except Exception:
            db.session.rollback()
            flash('Error creating user', 'error')
            return redirect(request.referrer or url_for('admin_panel'))

    @app.route('/program/<int:program_id>/edit')
    @admin_required
    def edit_program(program_id):
        try:
            program = WorkoutProgram.query.get_or_404(program_id)
            exercises = Exercise.query.all()
            workouts = ProgramWorkout.query.filter_by(program_id=program_id).order_by(ProgramWorkout.day_number).all()
            return render_template('edit_program.html', program=program, exercises=exercises, workouts=workouts)
        except Exception:
            flash('Error loading program', 'error')
            return redirect(url_for('coach_programs'))

    @app.route('/program/<int:program_id>/add_workout', methods=['POST'])
    @admin_required
    def add_workout(program_id):
        try:
            workout = ProgramWorkout(
                program_id=program_id,
                day_number=int(request.form['day_number']),
                name=request.form['name']
            )
            db.session.add(workout)
            db.session.commit()
            flash('Workout day added', 'success')
        except Exception:
            db.session.rollback()
            flash('Error adding workout', 'error')
        return redirect(url_for('edit_program', program_id=program_id))

    @app.route('/workout/<int:workout_id>/add_exercise', methods=['POST'])
    @admin_required
    def add_exercise_to_workout(workout_id):
        try:
            exercise = ProgramExercise(
                program_workout_id=workout_id,
                exercise_id=int(request.form['exercise_id']),
                sets=int(request.form['sets']),
                reps=int(request.form['reps']),
                notes=request.form.get('notes', ''),
                order=int(request.form.get('order', 0)),
                has_accommodating_resistance=bool(request.form.get('has_accommodating_resistance')),
                accommodating_resistance_type=request.form.get('accommodating_resistance_type', '')
            )
            db.session.add(exercise)
            db.session.commit()
            flash('Exercise added to workout', 'success')
        except Exception:
            db.session.rollback()
            flash('Error adding exercise', 'error')
        workout = ProgramWorkout.query.get(workout_id)
        return redirect(url_for('edit_program', program_id=workout.program_id))

    @app.route('/add_dummy_data')
    @admin_required
    def add_dummy_data():
        try:
            from datetime import datetime
            
            # Create competition exercises if they don't exist
            bench = Exercise.query.filter_by(name='Bench Press').first()
            if not bench:
                bench = Exercise(name='Bench Press', category='Bench', is_competition_lift=True)
                db.session.add(bench)
            
            squat = Exercise.query.filter_by(name='Squat').first()
            if not squat:
                squat = Exercise(name='Squat', category='Squat', is_competition_lift=True)
                db.session.add(squat)
            
            deadlift = Exercise.query.filter_by(name='Deadlift').first()
            if not deadlift:
                deadlift = Exercise(name='Deadlift', category='Deadlift', is_competition_lift=True)
                db.session.add(deadlift)
            
            db.session.commit()
            
            # Get a client user (non-admin)
            client = User.query.filter_by(is_admin=False).first()
            if not client:
                flash('No client found. Create a client first.', 'error')
                return redirect(url_for('coach_dashboard'))
            
            # Dummy data
            dummy_data = [
                ('2024-10-16', bench.id, 115, 1),
                ('2024-10-16', squat.id, 155, 1),
                ('2024-10-16', deadlift.id, 180, 1),
                ('2024-10-14', bench.id, 117.5, 1),
                ('2024-10-14', squat.id, 150, 1),
                ('2024-10-14', deadlift.id, 170, 1),
                ('2024-10-13', bench.id, 115, 1),
                ('2024-10-13', squat.id, 155, 1),
                ('2024-10-13', deadlift.id, 180, 1),
                ('2024-10-12', bench.id, 115, 1),
                ('2024-10-12', squat.id, 155, 1),
                ('2024-10-12', deadlift.id, 180, 1),
                ('2024-10-11', bench.id, 110, 1),
                ('2024-10-11', squat.id, 150, 1),
                ('2024-10-11', deadlift.id, 182.5, 1)
            ]
            
            for date_str, exercise_id, weight, reps in dummy_data:
                workout = Workout(
                    user_id=client.id,
                    exercise_id=exercise_id,
                    sets=1,
                    reps=reps,
                    weight=weight,
                    date=datetime.strptime(date_str, '%Y-%m-%d'),
                    is_completed=True
                )
                db.session.add(workout)
            
            db.session.commit()
            flash(f'Dummy data added successfully for client: {client.username}', 'success')
            
        except Exception as e:
            db.session.rollback()
            flash(f'Error adding dummy data: {str(e)}', 'error')
        
        return redirect(url_for('coach_dashboard'))

    @app.route('/delete_exercise/<int:exercise_id>', methods=['POST'])
    @admin_required
    def delete_exercise(exercise_id):
        try:
            exercise = Exercise.query.get_or_404(exercise_id)
            db.session.delete(exercise)
            db.session.commit()
            flash('Exercise deleted successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error deleting exercise', 'error')
        return redirect(url_for('coach_exercises'))

    @app.route('/delete_user/<int:user_id>', methods=['POST'])
    @admin_required
    def delete_user(user_id):
        try:
            user = User.query.get_or_404(user_id)
            db.session.delete(user)
            db.session.commit()
            flash('User deleted successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error deleting user', 'error')
        return redirect(url_for('coach_clients'))

    @app.route('/delete_program/<int:program_id>', methods=['POST'])
    @admin_required
    def delete_program(program_id):
        try:
            program = WorkoutProgram.query.get_or_404(program_id)
            db.session.delete(program)
            db.session.commit()
            flash('Program deleted successfully', 'success')
        except Exception:
            db.session.rollback()
            flash('Error deleting program', 'error')
        return redirect(url_for('coach_programs'))