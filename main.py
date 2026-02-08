import sys
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from core.db import noteDatabase
from core.get_info import notesInfo

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

backend_instance = noteDatabase()
notes_info = notesInfo(backend_instance)
backend_instance.notesInfo = notes_info

engine.rootContext().setContextProperty("interact_database", backend_instance)
engine.rootContext().setContextProperty("notes_info", notes_info)

engine.load('ui/main.qml')
if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())
