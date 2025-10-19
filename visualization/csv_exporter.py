import http.server
import socketserver
import csv
import os

PORT = 8000
CSV_FILE = '/csv-data/triage_results.csv'

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()

            # Help text for the Prometheus metric
            self.wfile.write(b'# HELP alert_count Total count of processed security alerts\n')
            self.wfile.write(b'# TYPE alert_count counter\n')

            alert_total = 0
            if os.path.exists(CSV_FILE):
                with open(CSV_FILE, 'r') as f:
                    # Count the number of rows, subtracting 1 for the header
                    alert_total = max(0, sum(1 for row in f) - 1)
            
            # Write the metric value
            self.wfile.write(f'alert_count_total {alert_total}\n'.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()