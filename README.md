# Proyecto
import datetime
import sqlite3
import logging

logging.basicConfig(filename='control_visitas.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class Visitante:
    def __init__(self, nombre, id_visitante, motivo_visita=None):
        self.nombre = nombre
        self.id_visitante = id_visitante
        self.entrada = None
        self.salida = None
        self.motivo_visita = motivo_visita

class Residente:
    def __init__(self, nombre, numero_casa, numero_documento):
        self.nombre = nombre
        self.numero_casa = numero_casa
        self.numero_documento = numero_documento
        self.impuestos = 0
        self.marca = False

class ControlVisitas:
    def __init__(self):
        self.visitantes = {}
        self.historial = []
        self.residentes = {}
        self.conexion = sqlite3.connect('control_visitas.db')
        self.cursor = self.conexion.cursor()
        self._crear_tablas()

    def _crear_tablas(self):
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS visitantes (
                id_visitante TEXT PRIMARY KEY,
                nombre TEXT,
                entrada TEXT,
                salida TEXT,
                motivo_visita TEXT
            )
        ''')
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS residentes (
                numero_documento TEXT PRIMARY KEY,
                nombre TEXT,
                numero_casa TEXT,
                impuestos REAL,
                marca INTEGER
            )
        ''')
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS historial (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                registro TEXT
            )
        ''')
        self.conexion.commit()
        logging.info("Tablas creadas o verificadas con éxito.")

    def registrar_entrada(self, id_visitante):
        if id_visitante in self.visitantes:
            visitante = self.visitantes[id_visitante]
            if visitante.entrada is None:
                motivo_visita = input("Ingrese el motivo de la visita: ")
                visitante.motivo_visita = motivo_visita
                visitante.entrada = datetime.datetime.now()
                entrada_str = visitante.entrada.strftime('%Y-%m-%d %H:%M:%S')
                self.cursor.execute('''
                    UPDATE visitantes SET entrada = ?, motivo_visita = ? WHERE id_visitante = ?
                ''', (entrada_str, motivo_visita, id_visitante))
                self.historial.append(f"Entrada registrada para {visitante.nombre} a las {entrada_str} con motivo: {motivo_visita}")
                logging.info(f"Entrada registrada para {visitante.nombre}")
                print(f"Entrada registrada para {visitante.nombre}")
            else:
                print("El visitante ya tiene una entrada registrada.")
        else:
            print("Visitante no encontrado.")

    def registrar_salida(self, id_visitante):
        if id_visitante in self.visitantes:
            visitante = self.visitantes[id_visitante]
            if visitante.entrada is not None:
                visitante.salida = datetime.datetime.now()
                salida_str = visitante.salida.strftime('%Y-%m-%d %H:%M:%S')
                self.cursor.execute('''
                    UPDATE visitantes SET salida = ? WHERE id_visitante = ?
                ''', (salida_str, id_visitante))
                self.historial.append(f"Salida registrada para {visitante.nombre} a las {salida_str}")
                logging.info(f"Salida registrada para {visitante.nombre}")
                print(f"Salida registrada para {visitante.nombre}")
            else:
                print("El visitante no tiene una entrada registrada.")
        else:
            print("Visitante no encontrado.")

    def ver_historial(self):
        for registro in self.historial:
            print(registro)

    def agregar_usuario(self, nombre, id_visitante):
        if id_visitante not in self.visitantes:
            self.visitantes[id_visitante] = Visitante(nombre, id_visitante)
            self.cursor.execute('''
                INSERT INTO visitantes (id_visitante, nombre, entrada, salida, motivo_visita) VALUES (?, ?, NULL, NULL, NULL)
            ''', (id_visitante, nombre))
            logging.info(f"Usuario {nombre} agregado con éxito.")
            print(f"Usuario {nombre} agregado con éxito.")
        else:
            print("El ID de visitante ya existe.")

    def cerrar_programa(self):
        print("Cerrando el programa...")
        self.conexion.commit()
        self.conexion.close()
        exit()

    def agregar_residente(self, nombre, numero_casa, numero_documento):
        if numero_documento not in self.residentes:
            self.residentes[numero_documento] = Residente(nombre, numero_casa, numero_documento)
            self.cursor.execute('''
                INSERT INTO residentes (numero_documento, nombre, numero_casa, impuestos, marca) VALUES (?, ?, ?, 0, 0)
            ''', (numero_documento, nombre, numero_casa))
            logging.info(f"Residente {nombre} agregado con éxito.")
            print(f"Residente {nombre} agregado con éxito.")
        else:
            print("El número de documento ya existe.")

    def editar_residente(self, numero_documento, nuevo_nombre=None, nuevo_numero_casa=None):
        if numero_documento in self.residentes:
            residente = self.residentes[numero_documento]
            if nuevo_nombre:
                residente.nombre = nuevo_nombre
                self.cursor.execute('''
                    UPDATE residentes SET nombre = ? WHERE numero_documento = ?
                ''', (nuevo_nombre, numero_documento))
            if nuevo_numero_casa:
                residente.numero_casa = nuevo_numero_casa
                self.cursor.execute('''
                    UPDATE residentes SET numero_casa = ? WHERE numero_documento = ?
                ''', (nuevo_numero_casa, numero_documento))
            logging.info(f"Residente {residente.nombre} editado con éxito.")
            print(f"Residente {residente.nombre} editado con éxito.")
        else:
            print("Residente no encontrado.")

    def agregar_impuestos(self, numero_documento, cantidad):
        if numero_documento in self.residentes:
            residente = self.residentes[numero_documento]
            residente.impuestos += cantidad
            self.cursor.execute('''
                UPDATE residentes SET impuestos = ? WHERE numero_documento = ?
            ''', (residente.impuestos, numero_documento))
            logging.info(f"Impuestos agregados para {residente.nombre}. Total: {residente.impuestos}")
            print(f"Impuestos agregados para {residente.nombre}. Total: {residente.impuestos}")
        else:
            print("Residente no encontrado.")

    def marcar_residente(self, numero_documento):
        if numero_documento in self.residentes:
            residente = self.residentes[numero_documento]
            residente.marca = True
            self.cursor.execute('''
                UPDATE residentes SET marca = 1 WHERE numero_documento = ?
            ''', (numero_documento,))
            logging.info(f"Residente {residente.nombre} marcado.")
            print(f"Residente {residente.nombre} marcado.")
        else:
            print("Residente no encontrado.")

    def verificar_base_datos(self):
        self.cursor.execute('''
            SELECT * FROM visitantes
        ''')
        visitantes = self.cursor.fetchall()
        print("Visitantes en la base de datos:")
        for visitante in visitantes:
            print(visitante)
        self.cursor.execute('''
            SELECT * FROM residentes
        ''')
        residentes = self.cursor.fetchall()
        print("Residentes en la base de datos:")
        for residente in residentes:
            print(residente)
        self.cursor.execute('''
            SELECT * FROM historial
        ''')
        historial = self.cursor.fetchall()
        print("Historial en la base de datos:")
        for registro in historial:
            print(registro)

def menu():
    control = ControlVisitas()
    while True:
        print("\nControl de Visitas")
        print("1. Registrar Entrada")
        print("2. Registrar Salida")
        print("3. Agregar Usuario")
        print("4. Agregar Residente")
        print("5. Editar Residente")
        print("6. Agregar Impuestos")
        print("7. Marcar Residente")
        print("8. Verificar Base de Datos")
        print("9. Ver Historial")
        print("10. Cerrar Programa")
        opcion = input("Seleccione una opción: ")
        if opcion == "1":
            id_visitante = input("Ingrese el ID del visitante: ")
            control.registrar_entrada(id_visitante)
        elif opcion == "2":
            id_visitante = input("Ingrese el ID del visitante: ")
            control.registrar_salida(id_visitante)
        elif opcion == "3":
            nombre = input("Ingrese el nombre del visitante: ")
            id_visitante = input("Ingrese el ID del visitante: ")
            control.agregar_usuario(nombre, id_visitante)
        elif opcion == "4":
            nombre = input("Ingrese el nombre del residente: ")
            numero_casa = input("Ingrese el número de casa: ")
            numero_documento = input("Ingrese el número de documento: ")
            control.agregar_residente(nombre, numero_casa, numero_documento)
        elif opcion == "5":
            numero_documento = input("Ingrese el número de documento del residente a editar: ")
            nuevo_nombre = input("Ingrese el nuevo nombre (dejar en blanco para no cambiar): ")
            nuevo_numero_casa = input("Ingrese el nuevo número de casa (dejar en blanco para no cambiar): ")
            control.editar_residente(numero_documento, nuevo_nombre if nuevo_nombre else None,
                                     nuevo_numero_casa if nuevo_numero_casa else None)
        elif opcion == "6":
            numero_documento = input("Ingrese el número de documento del residente: ")
            cantidad = float(input("Ingrese la cantidad de impuestos a agregar: "))
            control.agregar_impuestos(numero_documento, cantidad)
        elif opcion == "7":
            numero_documento = input("Ingrese el número de documento del residente a marcar: ")
            control.marcar_residente(numero_documento)
        elif opcion == "8":
            control.verificar_base_datos()
        elif opcion == "9":
            control.ver_historial()
        elif opcion == "10":
            control.cerrar_programa()
        else:
            print("Opción no válida. Por favor, intente de nuevo.")

if __name__ == "__main__":
    menu()
