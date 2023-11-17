import http.server
import socketserver
import os
import threading

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        # Mengganti jalur permintaan untuk mengarahkan ke direktori /sql
        return os.path.join(os.getcwd(), 'sql', os.path.normpath(path[len(self.path):]))

def start_server():
    # Konfigurasi server
    port = 8080
    handler = MyHandler

    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"Sedang berjalan di port {port}")
        httpd.serve_forever()

if __name__ == "__main__":
    # Menggunakan threading untuk menjalankan server di latar belakang
    server_thread = threading.Thread(target=start_server)
    server_thread.daemon = True
    server_thread.start()

    # Program utama dapat melanjutkan eksekusi atau keluar
    # Anda dapat menambahkan logika atau pekerjaan lain di sini

    # Contoh: Jalankan program utama dalam loop
    while True:
        pass
