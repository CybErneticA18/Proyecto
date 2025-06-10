# Proyecto
import datetime

class Visitante:
    def __init__(self, nombre, id_visitante):
        self.nombre = nombre
        self.id_visitante = id_visitante
        self.entrada = None
        self.salida = None

class ControlVisitas:
    def __init__(self):
        self.visitantes = {}
        self.historial = []

    def registrar_entrada(self, id_visitante):
        if id_visitante in self.visitantes:
            visitante = self.visitantes[id_visitante]
            if visitante.entrada is None:
                visitante.entrada = datetime.datetime.now()
                self.historial.append(f"Entrada registrada para {visitante.nombre} a las {visitante.entrada}")
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
                self.historial.append(f"Salida registrada para {visitante.nombre} a las {visitante.salida}")
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
            print(f"Usuario {nombre} agregado con éxito.")
        else:
            print("El ID de visitante ya existe.")

    def cerrar_programa(self):
        print("Cerrando el programa...")
        exit()

def menu():
    control = ControlVisitas()
    while True:
        print("\nControl de Visitas")
        print("1. Registrar Entrada")
        print("2. Registrar Salida")
        print("3. Ver Historial")
        print("4. Agregar Usuario")
        print("5. Cerrar Programa")
        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            id_visitante = input("Ingrese el ID del visitante: ")
            control.registrar_entrada(id_visitante)
        elif opcion == "2":
            id_visitante = input("Ingrese el ID del visitante: ")
            control.registrar_salida(id_visitante)
        elif opcion == "3":
            control.ver_historial()
        elif opcion == "4":
            nombre = input("Ingrese el nombre del visitante: ")
            id_visitante = input("Ingrese el ID del visitante: ")
            control.agregar_usuario(nombre, id_visitante)
        elif opcion == "5":
            control.cerrar_programa()
        else:
            print("Opción no válida. Por favor, intente de nuevo.")

if __name__ == "__main__":
    menu()
