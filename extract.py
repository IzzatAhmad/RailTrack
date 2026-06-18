import json
import sys

log_path = "C:\\Users\\izzatahmad\\.gemini\\antigravity-ide\\brain\\65e89b03-6b91-46ff-be44-27517023f812\\.system_generated\\logs\\transcript.jsonl"
last_input = ""

with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if data.get("type") == "USER_INPUT":
                last_input = data.get("content", "")
        except:
            pass

# Find the html part
idx = last_input.find("insert to rubrics\n")
if idx != -1:
    html = last_input[idx + len("insert to rubrics\n"):]
    with open("e:\\RailTrack\\RailTrack\\rubrics_html_to_insert.txt", 'w', encoding='utf-8') as out:
        out.write(html)
    print("Extracted HTML of length", len(html))
else:
    print("Could not find 'insert to rubrics'")
