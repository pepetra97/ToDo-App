from flask import Flask, request, jsonify, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///todo.db"
db = SQLAlchemy(app)

class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    task = db.Column(db.String(100), nullable=False)
    done = db.Column(db.Boolean, default=False)

@app.route('/')
def home():
    todos = Todo.query.all()
    return render_template('index.html', todos=todos)

@app.route('/add', methods=['POST'])
def add():
    task = request.form.get('task')
    new_todo = Todo(task=task, done=False)
    db.session.add(new_todo)
    db.session.commit()
    return redirect(url_for('home'))

@app.route('/mark_done/<int:todo_id>')
def mark_done(todo_id):
    todo = Todo.query.get(todo_id)
    todo.done = True
    db.session.commit()
    return redirect(url_for('home'))

@app.route('/delete/<int:todo_id>')
def delete(todo_id):
    todo = Todo.query.get(todo_id)
    db.session.delete(todo)
    db.session.commit()
    return redirect(url_for('home'))

@app.route('/toggle_done/<int:todo_id>')
def toggle_done(todo_id):
    todo = Todo.query.get(todo_id)
    todo.done = not todo.done
    db.session.commit()
    return redirect(url_for('home'))


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
