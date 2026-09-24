#!/usr/bin/env python3
"""grilling 라운드 페이지를 127.0.0.1 에서 서빙하고, 페이지가 보낸 답을 파일로 저장한다.

사용: serve.py <라운드 디렉토리> [--port N]
- GET  /<파일>          디렉토리 안의 파일만 준다 (하위 디렉토리 포함, 밖으로 나가는 경로는 404).
- GET  /answers/r<N>    r<N>-answers.json 을 준다. 없으면 null.
- POST /answers/r<N>    본문 JSON 을 r<N>-answers.json 에 저장한다 (임시 파일 → 교체).
시작하면 stdout 첫 줄에 `URL http://127.0.0.1:<port>/` 를 찍는다.
"""
import argparse, json, os, re, sys, tempfile
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ANSWER_PATH = re.compile(r"^/answers/(r\d{1,3})$")
MAX_BODY = 256 * 1024


def valid(doc, round_id):
    return (isinstance(doc, dict) and doc.get("round") == round_id
            and isinstance(doc.get("answers"), dict)
            and isinstance(doc.get("completed"), bool))


class Handler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def send_json(self, code, payload):
        body = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/favicon.ico":
            self.send_response(204)
            return self.end_headers()
        m = ANSWER_PATH.match(self.path.split("?")[0])
        if not m:
            return super().do_GET()
        path = os.path.join(self.directory, f"{m.group(1)}-answers.json")
        if not os.path.exists(path):
            return self.send_json(200, None)   # 아직 답 없음: 콘솔 오류 없이 null
        with open(path, encoding="utf-8") as f:
            self.send_json(200, json.load(f))

    def do_POST(self):
        m = ANSWER_PATH.match(self.path.split("?")[0])
        if not m:
            return self.send_json(404, {"error": "bad path"})
        length = int(self.headers.get("Content-Length") or 0)
        if length <= 0 or length > MAX_BODY:
            return self.send_json(413, {"error": "bad size"})
        try:
            doc = json.loads(self.rfile.read(length))
        except ValueError:
            return self.send_json(400, {"error": "bad json"})
        if not valid(doc, m.group(1)):
            return self.send_json(400, {"error": "bad shape"})
        target = os.path.join(self.directory, f"{m.group(1)}-answers.json")
        fd, tmp = tempfile.mkstemp(dir=self.directory, suffix=".tmp")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(doc, f, ensure_ascii=False, indent=2)
        os.replace(tmp, target)
        self.send_json(200, {"saved": True})


def main():
    p = argparse.ArgumentParser()
    p.add_argument("directory")
    p.add_argument("--port", type=int, default=0)
    a = p.parse_args()
    root = os.path.realpath(a.directory)
    server = ThreadingHTTPServer(("127.0.0.1", a.port),
                                 lambda *x, **k: Handler(*x, directory=root, **k))
    print(f"URL http://127.0.0.1:{server.server_address[1]}/", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    sys.exit(main())
