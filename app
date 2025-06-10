from flask import Flask, request, render_template, redirect, url_for
from datetime import datetime

app = Flask(__name__)

# Base de datos simulada
visitantes = {}
historial = []

class Visitante:
    def __init__(self, nombre, id_visitante):
        self.nombre = nombre
        self.id_visitante = id_visitante
        self.entrada = None
        self.salida = None

def registrar_entrada(id_visitante):
    if id_visitante in visitantes:
        visitante = visitantes[id_visitante]
        if visitante.entrada is None:
            visitante.entrada = datetime.now()
            historial.append(f"Entrada registrada para {visitante.nombre} a las {visitante.entrada}")
            return True
        else:
            return False
    else:
        return False

def registrar_salida(id_visitante):
    if id_visitante in visitantes:
        visitante = visitantes[id_visitante]
        if visitante.entrada is not None:
            visitante.salida = datetime.now()
            historial.append(f"Salida registrada para {visitante.nombre} a las {visitante.salida}")
            return True
        else:
            return False
    else:
        return False

def ver_historial():
    return historial

def agregar_usuario(nombre, id_visitante):
    if id_visitante not in visitantes:
        visitantes[id_visitante] = Visitante(nombre, id_visitante)
        return True
    else:
        return False

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/registrar_entrada', methods=['POST'])
def registrar_entrada_route():
    id_visitante = request.form['id_visitante']
    if registrar_entrada(id_visitante):
        return redirect(url_for('success'))
    else:
        return redirect(url_for('error'))

@app.route('/registrar_salida', methods=['POST'])
def registrar_salida_route():
    id_visitante = request.form['id_visitante']
    if registrar_salida(id_visitante):
        return redirect(url_for('success'))
    else:
        return redirect(url_for('error'))

@app.route('/ver_historial')
def ver_historial_route():
    return render_template('historial.html', historial=ver_historial())

@app.route('/agregar_usuario', methods=['POST'])
def agregar_usuario_route():
    nombre = request.form['nombre']
    id_visitante = request.form['id_visitante']
    if agregar_usuario(nombre, id_visitante):
        return redirect(url_for('success'))
    else:
        return redirect(url_for('error'))

@app.route('/success')
def success():
    return "Operación exitosa!"

@app.route('/error')
def error():
    return "Error en la operación."

if __name__ == '__main__':
    app.run(debug=True)
