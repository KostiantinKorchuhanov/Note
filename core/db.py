import sqlite3
import time
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from core.get_info import notesInfo


class noteDatabase(QObject):
    last_changed = pyqtSignal(str, str)
    search_results = pyqtSignal(list)

    def __init__(self):
        super().__init__()
        self.current_id = None
        self.connection = sqlite3.connect("database/notes.db")
        self.cursor = self.connection.cursor()
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS notestable(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                note TEXT,
                date REAL,
                title TEXT
            )
        ''')
        self.connection.commit()
        self.get_last_note()

    @pyqtSlot(str, str)
    def save_note(self, note_text, note_title):
        timestamp = int(time.time())

        if self.current_id is None:
            note_title = "Note" + str(timestamp)
            self.cursor.execute(
                'INSERT INTO notestable (note, date, title) VALUES (?, ?, ?)',
                (note_text, timestamp, note_title,)
            )
            self.current_id = self.cursor.lastrowid
        else:
            self.cursor.execute(
                'UPDATE notestable SET note = ?, date = ?, title = ? WHERE id = ?',
                (note_text, timestamp, note_title, self.current_id)
            )

        self.connection.commit()
        self.get_last_note()
        self.notesInfo.reload()

    @pyqtSlot()
    def create_new_note(self):
        timestamp = int(time.time())
        note_title = "Note" + str(int(time.time()))

        self.cursor.execute(
            '''
                INSERT INTO notestable (note, date, title) VALUES (?, ?, ?)
            ''',
            ("", timestamp, note_title)
        )
        self.connection.commit()
        self.current_id = self.cursor.lastrowid
        self.last_changed.emit("", note_title)
        self.notesInfo.reload()

    @pyqtSlot()
    def get_last_note(self):
        self.cursor.execute(
            'SELECT id, note, title FROM notestable ORDER BY date DESC LIMIT 1'
        )
        row = self.cursor.fetchone()
        if row:
            self.current_id = row[0]
            self.last_changed.emit(row[1], row[2])

    @pyqtSlot(int)
    def select_note(self, note_id):
        self.current_id = note_id
        self.cursor.execute(
            '''
                SELECT note, title FROM notestable WHERE id = ?
            ''',
            (note_id,)
        )
        row = self.cursor.fetchone()
        if row:
            self.last_changed.emit(row[0], row[1])

    @pyqtSlot()
    def delete_note(self):
        self.cursor.execute(
            '''
                SELECT COUNT(*) FROM notestable
            '''
        )
        count = self.cursor.fetchone()[0]

        if count <= 1:
            return

        self.cursor.execute(
            '''
                DELETE FROM notestable WHERE id = ?
            ''',
            (self.current_id,)
        )
        self.connection.commit()
        self.get_last_note()
        self.notesInfo.reload()

    @pyqtSlot(str)
    def search_note(self, word):
        results = []
        self.cursor.execute(
            '''
                SELECT id, title, note FROM notestable
            '''
        )
        notes = self.cursor.fetchall()
        for note_id, note_title, note_text in notes:
            lines = note_text.splitlines()
            for i, line in enumerate(lines):
                if word.lower() in line.lower():
                    results.append({
                        "note_id": note_id,
                        "note_title": note_title,
                        "line_number": i + 1,
                        "note_text": line
                    })
        self.search_results.emit(results)



